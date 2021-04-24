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

def repair_hard_encode(ast, charno):
    hard_encode_cnt = 0
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            # it is in a function
            if defectNode.father.father.nodeType == 'FunctionDefinition':
                literalNode = None
                nodeQ = Queue()
                nodeQ.put(defectNode) # root
                while(not nodeQ.empty()):
                    tmpNode = nodeQ.get()
                    if hasattr(tmpNode, 'attributes') and 'value' in tmpNode.attributes.keys():
                        if tmpNode.attributes['value'] != None and tmpNode.attributes['value'].startswith('0x'):
                            literalNode =  tmpNode
                    for childNode in tmpNode.children:
                        nodeQ.put(childNode)

                # if literalNode.father.nodeType == 'IndexAccess':
                #     goalType = 'address' # currently this way
                # else:

                #     goalType = defectNode.children[0].children[0].attributes['type']
                goalType = 'address'
                #print(goalType)

                funcDefNode = defectNode.father.father
                typeNode = TreeNode('ElementaryTypeName')
                typeNode.beginPoint = -1
                typeNode.attributes = {}
                typeNode.attributes['name'] = goalType
                typeNode.attributes['type'] = goalType
                varDecNode = TreeNode('VariableDeclaration')
                varDecNode.beginPoint = -1
                varDecNode.attributes = {}
                varDecNode.attributes['name'] = 'param' + str(hard_encode_cnt)
                varDecNode.children.append(typeNode)
                funcDefNode.children[0].children.append(varDecNode)

                idenNode = TreeNode('Identifier')
                idenNode.beginPoint = -1
                idenNode.attributes = {}
                idenNode.attributes['value'] = 'param' + str(hard_encode_cnt)
                idx = literalNode.father.children.index(literalNode)
                literalNode.father.children[idx] = idenNode

            else:
                # print('cannot repair it')
                pass

            hard_encode_cnt += 1
        
        except:
            print('failing to repair the hard encode defect in charnum:' + str(num))
            continue