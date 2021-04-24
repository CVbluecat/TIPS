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

def repair_misleading_dataloc(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            
            funcCallNode = TreeNode('FunctionCall')
            newNode = TreeNode('NewExpression')
            funcCallNode.beginPoint = -1
            newNode.beginPoint = -1
            idenNode = defectNode.children[0].children[0]
            newNode.children.append(idenNode)
            funcCallNode.children.append(newNode)
            defectNode.children.append(funcCallNode)

        except:
            print('failing to repair the misleading defect in charnum:' + str(num))
            continue