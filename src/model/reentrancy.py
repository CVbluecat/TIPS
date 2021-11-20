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
    blockNode = TreeNode('Block')
    blockNode.children.append(node)
    return blockNode

# usually use the pattern call.value
def repair_reentrancy1(ast, charno):
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

            if valueNode == None:
                return

            # param1 = valueNode.father.children[1].attributes['value']
            # paramNode = valueNode.father.children[1]
            callNode = None
            nodeQ = Queue()
            nodeQ.put(valueNode) # root
            while(not nodeQ.empty()):
                tmpNode = nodeQ.get()
                if 'member_name' in tmpNode.attributes.keys() and tmpNode.attributes['member_name'] == 'call':
                    callNode =  tmpNode
                    break
                for childNode in tmpNode.children:
                    nodeQ.put(childNode)

            if callNode == None:
                return

            addressNode = callNode.children[0]
            valueNode.attributes['member_name'] = 'send'
            valueNode.children[0] = addressNode


            if curNodeType == 'IfStatement':
                funccallNode = valueNode.father
                # !(call.value())
                if defectNode.children[0].nodeType == 'UnaryOperation' and defectNode.children[0].attributes['operator'] == '!':
                    modifyNode = defectNode.children[0]
                    if(modifyNode.children[0].nodeType == 'TupleExpression'):
                        modifyNode.children[0].children[0] = funccallNode
                    else:
                        modifyNode.children[0] = funccallNode
                
                # call.value
                else:
                    defectNode.children[0] = funccallNode
                    if len(defectNode.children) <3:
                        defectNode.children.append(generateThrowNode())
                

            elif curNodeType == 'ExpressionStatement':
                funccallNode = valueNode.father
                if(defectNode.children[0].nodeType == 'FunctionCall'):
                    defectNode.children[0].children[1] = funccallNode
                elif defectNode.children[0].nodeType == 'UnaryOperation':
                    defectNode.children[0].children[0] = funccallNode
            
            elif curNodeType == 'VariableDeclarationStatement':
                funccallNode = valueNode.father
                defectNode.children[1] = funccallNode
        
        except:
            print('failing to repair the reentrancy defect in charnum:' + str(num))
            continue
            
def repair_reentrancy2(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            contractNode = defectNode
            while contractNode.nodeType != 'ContractDefinition':
                contractNode = contractNode.father
            
            state_var = []
            for node in contractNode.children:
                if node.nodeType == 'VariableDeclaration':
                    state_var.append(node.attributes['name'])
            
            defect_idx = defectNode.father.children.index(defectNode)
            modify_list = []
            for idx in range(defect_idx+1,len(defectNode.father.children)):
                curNode = defectNode.father.children[idx]
                nodeQ = Queue()
                nodeQ.put(curNode)
                while(not nodeQ.empty()):
                    tmpNode = nodeQ.get()
                    if tmpNode.nodeType == 'Identifier' and tmpNode.attributes['value'] in state_var:
                        modify_list.append(idx)
                        break
                    for childNode in tmpNode.children:
                        nodeQ.put(childNode)

            insertpool = []
            for item in reversed(modify_list):
                insertpool.append(defectNode.father.children[item])

            for item in insertpool:
                defectNode.father.children.remove(item)
                defectNode.father.children.insert(defect_idx, item)


        except:
            print('failing to repair the reentrancy defect in charnum:' + str(num))
            continue