from queue import Queue
from generateAST import TreeNode

# tranverse the tree to find the defect node
def BFSGetNode(ast, num):
    nodeQ = Queue()
    nodeQ.put(ast) # root
    while(not nodeQ.empty()):
        tmpNode = nodeQ.get()
        if tmpNode.beginPoint == num:
            return tmpNode
        for childNode in tmpNode.children:
            nodeQ.put(childNode)
    return None

def generateRequire():
    node = TreeNode('FunctionCall')
    identifierNode = TreeNode('Identifier')
    identifierNode.attributes = {}
    identifierNode.attributes['value'] = 'require'
    node.children.append(identifierNode)
    return node

def generateExpStatement():
    node = TreeNode('ExpressionStatement')
    node.beginPoint = -1
    return node

def generateBinaryExp(operator, lnode, rnode):
    node = TreeNode('BinaryOperation')
    node.attributes = {}
    node.attributes['operator'] = operator
    node.children.append(lnode)
    node.children.append(rnode)
    return node

def generateJudgeZero(rnode):
    node = TreeNode('IfStatement')
    zeroNode = TreeNode('Literal')
    zeroNode.attributes = {}
    zeroNode.attributes['value'] = '0'
    zeroNode.attributes['token'] = 'number'
    binaryNode = generateBinaryExp('!=', rnode, zeroNode)
    node.children.append(binaryNode)
    return node

def repair_first_type(ast, operator, assign):
    lNode = assign.children[0]
    rNode = assign.children[1]
    requireNode = generateRequire()
    binaryNode = generateBinaryExp('>=', lNode, rNode)
    expStatementNode = generateExpStatement()
    requireNode.children.append(binaryNode)
    expStatementNode.children.append(requireNode)
    opStatementNode = assign.father
    orgBlockNode = opStatementNode.father

    idx = orgBlockNode.children.index(opStatementNode)
    if operator == '+=':
        orgBlockNode.children.insert(idx+1, expStatementNode)

    elif operator == '-=':
        orgBlockNode.children.insert(idx, expStatementNode)

    elif operator == '*=':
        # generate a statement: uint tmp = ?
        tmpVarNode = TreeNode('VariableDeclarationStatement')
        leftNode = TreeNode('VariableDeclaration')
        leftNode.attributes = {'name':'tmp'}
        eletypeNode = TreeNode('ElementaryTypeName')
        eletypeNode.attributes = {'name':'uint'}
        leftNode.children.append(eletypeNode)
        rightNode = TreeNode('Identifier')
        rightNode.attributes = {'value': lNode.attributes['value']}
        tmpVarNode.children.append(leftNode)
        tmpVarNode.children.append(rightNode)

        judgeIfZero = generateJudgeZero(rNode)
        requireNode1 = generateRequire()
        binaryNode1 = generateBinaryExp('/', lNode, rNode)

        tmpIdNode = TreeNode('Identifier')
        tmpIdNode.attributes = {'value':'tmp'}

        binaryTotal1 = generateBinaryExp('==', binaryNode1, tmpIdNode)
        requireNode1.children.append(binaryTotal1)
        expNode1 = generateExpStatement()
        expNode1.children.append(requireNode1)
        judgeIfZero.children.append(expNode1)

        orgBlockNode.children.insert(idx+1, tmpVarNode)
        orgBlockNode.children.insert(idx+2,judgeIfZero)
    elif operator == '/=':
        pass    

def repair_second_type(ast, varDec):
    newvarNode = TreeNode('Identifier')
    newvarNode.attributes = {}
    newvarNode.attributes['value'] = varDec.children[0].attributes['name']

    if(varDec.children[1].nodeType == 'BinaryOperation'):
        lnode = varDec.children[1].children[0]
        rnode = varDec.children[1].children[1]
        operator = varDec.children[1].attributes['operator']
        
        if operator == '+':
            requireNode = generateRequire()
            binaryNode1 = generateBinaryExp('>=', newvarNode, lnode)
            binaryNode2 = generateBinaryExp('>=', newvarNode, rnode)
            binaryTotal = generateBinaryExp('&&', binaryNode1, binaryNode2)
            
            expStatementNode = generateExpStatement()
            requireNode.children.append(binaryTotal)
            expStatementNode.children.append(requireNode)

            orgBlockNode = varDec.father

            idx = orgBlockNode.children.index(varDec)
            
            orgBlockNode.children.insert(idx+1, expStatementNode)
        elif operator == '-':
            requireNode = generateRequire()
            binaryTotal = generateBinaryExp('>=', lnode, rnode)
            
            expStatementNode = generateExpStatement()
            requireNode.children.append(binaryTotal)
            expStatementNode.children.append(requireNode)

            orgBlockNode = varDec.father

            idx = orgBlockNode.children.index(varDec)
            orgBlockNode.children.insert(idx, expStatementNode)
        elif operator == '*':
            judgeIfZero1 = generateJudgeZero(lnode)
            requireNode1 = generateRequire()
            binaryNode1 = generateBinaryExp('/', newvarNode, lnode)
            binaryTotal1 = generateBinaryExp('==', binaryNode1, rnode)
            requireNode1.children.append(binaryTotal1)
            expNode1 = generateExpStatement()
            expNode1.children.append(requireNode1)
            judgeIfZero1.children.append(expNode1)

            judgeIfZero2 = generateJudgeZero(rnode)
            requireNode2 = generateRequire()
            binaryNode2 = generateBinaryExp('/', newvarNode, rnode)
            binaryTotal2 = generateBinaryExp('==', binaryNode2, lnode)
            requireNode2.children.append(binaryTotal2)
            expNode2 = generateExpStatement()
            expNode2.children.append(requireNode2)
            judgeIfZero2.children.append(expNode2)

            orgBlockNode = varDec.father

            idx = orgBlockNode.children.index(varDec)
            orgBlockNode.children.insert(idx+1, judgeIfZero1)
            orgBlockNode.children.insert(idx+1, judgeIfZero2)
        elif operator == '/':
            pass
    else:
        pass

def repair_arithmetic(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            if defectNode.nodeType == 'ExpressionStatement':
                childNode = defectNode.children[0]
                operator = childNode.attributes['operator']
                repair_first_type(ast, operator, childNode)
            elif defectNode.nodeType == 'VariableDeclarationStatement':
                repair_second_type(ast, defectNode)
            else:
                pass
        except:
            print('failing to repair the arithmetic defect in charnum:' + str(num))
            continue