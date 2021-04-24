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

def generateThrowNode():
    node = TreeNode('Throw')
    node.beginPoint = -1
    return node

def generateIfNode():
    node = TreeNode('IfStatement')
    node.beginPoint = -1
    node.attributes = {}
    node.attributes['falseBody'] = None
    return node

def generateUnaryNode():
    node = TreeNode('UnaryOperation')
    node.beginPoint = -1
    node.attributes = {}
    node.attributes['isLValue'] = False
    node.attributes['operator'] = '!'
    node.attributes['prefix'] = True
    return node

def repair_unchecked_call1(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            # print(defectNode.nodeType)
            if defectNode == None:
                return ast
            fatherNode = defectNode.father
            if defectNode.nodeType == 'VariableDeclarationStatement':
                identified = TreeNode('Identifier')
                identified.beginPoint = -1
                identified.attributes = {}
                identified.attributes['value'] = defectNode.children[0].attributes['name']
                ifNode = generateIfNode()
                throwNode = generateThrowNode()
                unaryNode = generateUnaryNode()
                idx = fatherNode.children.index(defectNode)

                unaryNode.children.append(identified)
                ifNode.children.append(unaryNode)
                ifNode.children.append(throwNode)
                fatherNode.children.insert(idx+1, ifNode)
                continue


            # find whether using call.value or send
            exist = None
            nodeQ = Queue()
            nodeQ.put(defectNode) # root
            while(not nodeQ.empty()):
                tmpNode = nodeQ.get()
                if 'member_name' in tmpNode.attributes.keys() and tmpNode.attributes['member_name'] == 'value':
                    exist = tmpNode
                    break
                for childNode in tmpNode.children:
                    nodeQ.put(childNode)

            functionCallNode = defectNode.children[0]
            
            # maybe have bug
            if(functionCallNode.children[0].nodeType != 'FunctionCall' and exist != None and len(exist.children) > 0 \
                and 'member_name' in exist.children[0].attributes.keys() and exist.children[0].attributes['member_name'] == 'call'):
                functionNode = TreeNode('FunctionCall')
                functionNode.beginPoint = -1
                functionNode.children.append(functionCallNode)
                functionCallNode = functionNode
            # find idx in children
            idx = fatherNode.children.index(defectNode)
            
            ifNode = generateIfNode()
            throwNode = generateThrowNode()
            unaryNode = generateUnaryNode()

            unaryNode.children.append(functionCallNode)
            ifNode.children.append(unaryNode)
            ifNode.children.append(throwNode)
            fatherNode.children[idx] = ifNode
        
        except:
            print('failing to repair the unchecked call defect in charnum:' + str(num) + ' in type1')
            continue


def repair_unchecked_call2(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            curNodeType = defectNode.nodeType
            # print(curNodeType)
            # if(call.value)
            valueNode = None
            nodeQ = Queue()
            nodeQ.put(defectNode) # root
            while(not nodeQ.empty()):
                tmpNode = nodeQ.get()
                if 'member_name' in tmpNode.attributes.keys() and tmpNode.attributes['member_name'] == 'value':
                    valueNode =  tmpNode
                    break
                for childNode in tmpNode.children:
                    nodeQ.put(childNode)

            callNode = None
            nodeQ = Queue()
            nodeQ.put(defectNode) # root
            while(not nodeQ.empty()):
                tmpNode = nodeQ.get()
                if 'member_name' in tmpNode.attributes.keys() and tmpNode.attributes['member_name'] == 'call':
                    callNode =  tmpNode
                    break
                for childNode in tmpNode.children:
                    nodeQ.put(childNode)
            # call.value
            if valueNode == None or callNode == None:
                # send
                sendNode = None
                nodeQ = Queue()
                nodeQ.put(defectNode) # root
                while(not nodeQ.empty()):
                    tmpNode = nodeQ.get()
                    if 'member_name' in tmpNode.attributes.keys() and tmpNode.attributes['member_name'] == 'send':
                        sendNode =  tmpNode
                        break
                    for childNode in tmpNode.children:
                        nodeQ.put(childNode)
                sendNode.attributes['member_name'] = 'transfer'

            else:
                addressNode = callNode.children[0]
                valueNode.attributes['member_name'] = 'transfer'
                valueNode.children[0] = addressNode
                identiNode = valueNode.father.children[1]
                defectNode.children[0].children = []
                defectNode.children[0].children.append(valueNode)
                defectNode.children[0].children.append(identiNode)

        except:
            print('failing to repair the unchecked call defect in charnum:' + str(num) + ' in type2')
            continue
