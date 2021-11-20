from queue import Queue
from generateAST import TreeNode
from string import digits

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

def repair_unmatched_type(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            
            decNode = None
            nodeQ = Queue()
            nodeQ.put(defectNode) # root
            while(not nodeQ.empty()):
                tmpNode = nodeQ.get()
                if tmpNode.nodeType == 'VariableDeclaration':
                    decNode = tmpNode
                    break
                for childNode in tmpNode.children:
                    nodeQ.put(childNode)
                
            if len(decNode.children) > 0:
                oriType = decNode.children[0].attributes['name']
                curType = oriType.translate(str.maketrans('', '', digits))
                decNode.children[0].attributes['name'] = curType
                decNode.children[0].attributes['type'] = curType
            else:
                # handle the var
                typeNode = TreeNode('ElementaryTypeName')
                typeNode.attributes = {}
                typeNode.attributes['name'] = 'uint'
                typeNode.attributes['type'] = 'uint'
                decNode.children.append(typeNode)
        
        except:
            print('failing to repair the unmatched type defect in charnum:' + str(num))
            continue