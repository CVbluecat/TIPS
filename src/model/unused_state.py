from queue import Queue
from generateAST import TreeNode

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

def repair_unused_state(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            fatherNode = defectNode.father
            
            # directly remove the statement
            fatherNode.children.remove(defectNode)
        except:
            print('failing to repair the unused states defect in charnum:' + str(num))
            continue