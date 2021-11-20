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

def repair_strict_balance(ast, charno):
    for num in charno:
        try:
            defectNode = BFSGetNode(ast, num)
            # find this.balance

            thisNode = None
            nodeQ = Queue()
            nodeQ.put(defectNode) # root
            while(not nodeQ.empty()):
                tmpNode = nodeQ.get()
                if 'value' in tmpNode.attributes.keys() and tmpNode.attributes['value'] == 'this':
                    thisNode = tmpNode
                for childNode in tmpNode.children:
                    nodeQ.put(childNode)
            
            binaryOpNode = thisNode.father.father
            binaryOpNode1 = copy.deepcopy(binaryOpNode)
            binaryOpNode2 = copy.deepcopy(binaryOpNode)
            # >= 
            binaryOpNode1.attributes['operator'] = '>='
            binaryOpNode2.attributes['operator'] = '<'

            origvalNode = binaryOpNode2.children[1] # maybe behind is an expression
            tmpBinaryNode = TreeNode('BinaryOperation')
            tmpBinaryNode.beginPoint = -1
            tmpBinaryNode.attributes = {}
            tmpBinaryNode.attributes['operator'] = '+'
            oneNode = TreeNode('Literal')
            oneNode.attributes = {}
            oneNode.attributes['value'] = '1'
            oneNode.attributes['token'] = 'number'
            tmpBinaryNode.children.append(origvalNode)
            tmpBinaryNode.children.append(oneNode)
            secTuple = TreeNode('TupleExpression')
            secTuple.attributes = {'isInlineArray':False}
            secTuple.children.append(tmpBinaryNode)
            binaryOpNode2.children[1] = secTuple

            binaryOpNodeTotal = TreeNode('BinaryOperation')
            binaryOpNodeTotal.attributes = {}
            binaryOpNodeTotal.attributes['operator'] = '&&'

            tupleNode1 = TreeNode('TupleExpression')
            tupleNode1.attributes = {'isInlineArray':False}
            tupleNode1.children.append(binaryOpNode1)
            tupleNode2 = TreeNode('TupleExpression')
            tupleNode2.attributes = {'isInlineArray':False}
            tupleNode2.children.append(binaryOpNode2)

            binaryOpNodeTotal.children.append(tupleNode1)
            binaryOpNodeTotal.children.append(tupleNode2)

            upNode = binaryOpNode.father
            idx = upNode.children.index(binaryOpNode)
            upNode.children[idx] = binaryOpNodeTotal
        
        except:
            print('failing to repair the strict balance defect in charnum:' + str(num))
            continue