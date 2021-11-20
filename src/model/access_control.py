from queue import Queue
from generateAST import TreeNode
import copy

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

def repair_wrong_constructor(funcNode):
    funcNode.attributes['isConstructor'] = True

def existTxNode(defectNode):
    nodeQ = Queue()
    nodeQ.put(defectNode) # root
    while(not nodeQ.empty()):
        tmpNode = nodeQ.get()
        if 'value' in tmpNode.attributes.keys() and tmpNode.attributes['value'] == 'tx':
            return True
        for childNode in tmpNode.children:
            nodeQ.put(childNode)
    return False

def repair_tx_origin(defectNode):
    txNode = None
    nodeQ = Queue()
    nodeQ.put(defectNode) # root
    while(not nodeQ.empty()):
        tmpNode = nodeQ.get()
        if 'value' in tmpNode.attributes.keys() and tmpNode.attributes['value'] == 'tx':
            txNode = tmpNode
        for childNode in tmpNode.children:
            nodeQ.put(childNode)
    originNode = txNode.father
    txNode.attributes['value'] = 'msg'
    originNode.attributes['member_name'] = 'sender'

def add_require_protect(defectNode):
    # find the contract node
    contractNode = defectNode
    while contractNode.nodeType != 'ContractDefinition':
        contractNode = contractNode.father
    
    state_var = []
    for item in contractNode.children:
        if item.nodeType == 'VariableDeclaration':
            if len(item.children) > 0 and item.children[0].nodeType == 'ElementaryTypeName' and item.children[0].attributes['name'] == 'address':
                state_var.append(item.attributes['name'])
    owner_var = ''
    
    for var in state_var:
        if 'owner' in var or 'create' in var or 'admin' in var:
            owner_var = var
            break
    
    if owner_var == '' and len(state_var) > 0:
        owner_var = state_var[0]
    
    if len(state_var) == 0:
        # add a variable declaration and insert into constructor
        owner_idennode = TreeNode('VariableDeclaration')
        owner_idennode.attributes = {'name':'contractOwner'}
        ele_node = TreeNode('ElementaryTypeName')
        ele_node.attributes = {'name':'address', 'value':'address'}
        owner_idennode.children.append(ele_node)

        idx = 0
        while idx < len(contractNode.children):
            if contractNode.children[idx].nodeType != 'InheritanceSpecifier':
                break
            idx+=1

        constructorNode = ''
        for child in contractNode.children:
            if child.nodeType == 'FunctionDefinition' and child.attributes['isConstructor'] == True:
                constructorNode = child
                break
        
        param_node = copy.deepcopy(owner_idennode)
        param_node.attributes['name'] = '_owner'
        # constructorNode.children[0].children.append(param_node)
        for ele in constructorNode.children:
            if ele.nodeType == 'ParameterList':
                ele.children.append(param_node)
                break

        expNode = TreeNode('ExpressionStatement')
        curbinaryOpNode = TreeNode('BinaryOperation')
        curbinaryOpNode.attributes = {}
        curbinaryOpNode.attributes['operator'] = '='

        left_node = TreeNode('Identifier')
        left_node.attributes = {'value':'contractOwner'}
        right_node = TreeNode('Identifier')
        right_node.attributes = {'value':'_owner'}

        curbinaryOpNode.children.append(left_node)
        curbinaryOpNode.children.append(right_node)
        expNode.children.append(curbinaryOpNode)
        # constructorNode.children[2].children.insert(0, expNode)
        for ele in constructorNode.children:
            if ele.nodeType == 'Block':
                ele.children.append(expNode)
                break

        contractNode.children.insert(idx, owner_idennode)
        owner_var = 'contractOwner'

    # add a require(xxx == msg.sender)
    fatherNode = defectNode.father
    idx = fatherNode.children.index(defectNode)
    # msg.sender
    memaccNode = TreeNode('MemberAccess')
    memaccNode.attributes = {}
    memaccNode.attributes['member_name'] = 'sender'
    idenNode = TreeNode('Identifier')
    idenNode.attributes = {}
    idenNode.attributes['value'] = 'msg'
    memaccNode.children.append(idenNode)

    reqexpNode = TreeNode('ExpressionStatement')
    requireNode = TreeNode('FunctionCall')
    nameNode = TreeNode('Identifier')
    nameNode.attributes = {}
    nameNode.attributes['value'] = 'require'
    binaryOpNode = TreeNode('BinaryOperation')
    binaryOpNode.beginPoint = -1
    binaryOpNode.attributes = {}
    binaryOpNode.attributes['operator'] = '=='
    userdefNode = TreeNode('Identifier')
    userdefNode.attributes = {}
    userdefNode.attributes['value'] = owner_var
    binaryOpNode.children.append(userdefNode)
    binaryOpNode.children.append(memaccNode)
    requireNode.children.append(nameNode)
    requireNode.children.append(binaryOpNode)
    reqexpNode.children.append(requireNode)

    fatherNode.children.insert(idx, reqexpNode)


def repair_access_control(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            # wrong constructor name
            if defectNode.nodeType == 'FunctionDefinition':
                repair_wrong_constructor(defectNode)
            # tx.origin
            elif existTxNode(defectNode):
                repair_tx_origin(defectNode)
            else:
                add_require_protect(defectNode)
        except:
            print('failing to repair the access control defect in charnum:' + str(num))
            continue