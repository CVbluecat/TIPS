# Try to traverse the AST using the native way. Not modify the structure of the original parser result

import json
import queue
import os

# every node needs to have following attributes:
# nodeType: the type of the node, e.g. VariableDeclaration
# children: the child nodes of the current node
# id
# beginPoint: the beginning in the character-based code
# endPoint: the end in the character-based code
# attribute: the attributes of this type, we currently don't modify it
class TreeNode:
    def __init__(self, nodeType):
        self.nodeType = nodeType
        self.children = []
    
    def addChild(self, node):
        self.children.append(node)


# The highest level to handle the ast
# def generateAST(codepath):
#     fd = open(codepath)
#     content = json.loads(fd.read())
#     root = TreeNode(content['name'])
def generateAST(astcontent):
    content = json.loads(astcontent)
    root = TreeNode(content['name'])
    root.father = None
    
    if 'id' in content.keys():
        root.id = content['id']
    
    if 'attributes' in content.keys():
        root.attributes = content['attributes']
    else:
        root.attributes = {}
    # root.value = ""

    if 'src' in content.keys():
        characterPos = content['src'].split(':')
        root.beginPoint = int(characterPos[0])
        root.endPoint = int(characterPos[0]) + int(characterPos[1])
    else:
        root.beginPoint = -1
        root.endPoint = -1
    
    childNodes = content['children']
    for item in childNodes:
        node = generateNodes(item, root)
        root.addChild(node)
    return root

def generateNodes(node, father):
    curNode = TreeNode(node['name'])
    curNode.father = father
    curNode.id = node['id']
    characterPos = node['src'].split(':')
    curNode.beginPoint = int(characterPos[0])
    curNode.endPoint = int(characterPos[0]) + int(characterPos[1])
    if 'attributes' in node.keys():
        curNode.attributes = node['attributes']
    else:
        curNode.attributes = {}
    if('children' in node.keys()):
        childNodes = node['children']
    else:
        childNodes = []
    for item in childNodes:
        tmpNode = generateNodes(item, curNode)
        curNode.addChild(tmpNode)
    return curNode


def regenerateCode(root):
    codestr = ""
    for item in root.children:
        codestr += switchHandler(item)
    return codestr

def switchHandler(node):
    if node.nodeType == 'PragmaDirective':
        return pragmaHandler(node)
    elif node.nodeType == 'ContractDefinition':
        return contractDefHandler(node) 
    elif node.nodeType == 'VariableDeclaration':
        return variableDecHandler(node)
    elif node.nodeType == 'FunctionDefinition':
        return functionDefHandler(node)
    elif node.nodeType == 'Block':
        return blockHandler(node)
    elif node.nodeType == 'Assignment':
        return assignmentHandler(node)
    elif node.nodeType == 'Identifier':
        return identifierHandler(node)
    elif node.nodeType == 'Literal':
        return literalHandler(node)
    elif node.nodeType == 'ExpressionStatement':
        return expStatementHandler(node)
    elif node.nodeType == 'MemberAccess':
        return memberAccessHandler(node)
    elif node.nodeType == 'Return':
        return returnHandler(node)
    elif node.nodeType == 'ParameterList':
        return parameterListHandler(node)
    elif node.nodeType == 'EventDefinition':
        return eventDefHandler(node)
    elif node.nodeType == 'FunctionCall':
        return funcCallHandler(node)
    elif node.nodeType == 'BinaryOperation':
        return binaryOpHandler(node)
    elif node.nodeType == 'ModifierDefinition':
        return modifierDefHandler(node)
    elif node.nodeType == 'Conditional':
        return conditionalHandler(node)
    elif node.nodeType == 'PlaceholderStatement':
        return phStatementHandler(node)
    elif node.nodeType == 'IfStatement':
        return ifStatementHandler(node)
    elif node.nodeType == 'Throw':
        return throwHandler(node)
    elif node.nodeType == 'UnaryOperation':
        return unaryOpHandler(node)
    elif node.nodeType == 'ModifierInvocation':
        return modifierInvHandler(node)
    elif node.nodeType == 'IndexAccess':
        return indexAccessHandler(node)
    elif node.nodeType == 'StructDefinition':
        return structDefHandler(node)
    elif node.nodeType == 'VariableDeclarationStatement':
        return varDecStatementHandler(node)
    elif node.nodeType == 'ElementaryTypeNameExpression':
        return eleTypeNameExpHandler(node)
    elif node.nodeType == 'ForStatement':
        return forStatementHandler(node)
    elif node.nodeType == 'EmitStatement':
        return emitStatementHandler(node)
    elif node.nodeType == 'TupleExpression':
        return tupleExpHandler(node)
    elif node.nodeType == 'NewExpression':
        return newExpHandler(node)
    elif node.nodeType == 'WhileStatement':
        return whileStatementHandler(node)
    elif node.nodeType == 'InlineAssembly':
        return inlineAssemblyHandler(node)
    elif node.nodeType == 'UsingForDirective':
        return usingforDirectiveHandler(node)
    elif node.nodeType == 'UserDefinedTypeName':
        return userDefTypeNameHandler(node)
    elif node.nodeType == 'ElementaryTypeName':
        return elementaryTypeNameHandler(node)
    elif node.nodeType == 'EnumDefinition':
        return enumDefHandler(node)
    elif node.nodeType == 'Mapping':
        return mappingHandler(node)
    elif node.nodeType == 'ArrayTypeName':
        return arrayTypeHandler(node)
    else:
        return ""

def pragmaHandler(node):
    literal = node.attributes['literals']
    codestr = ""
    # native case
    if(literal[0] == 'solidity'):
        codestr += 'pragma solidity '
        for i in range(1, len(literal)):
            codestr += literal[i]
    return codestr + ';\n'

def contractDefHandler(node):
    codestr = ""
    attributes = node.attributes
    if 'contractKind' not in attributes.keys():
        codestr += 'contract ' + attributes['name']
    else:
        codestr += attributes['contractKind'] + ' ' + attributes['name']

    # Inherit
    cnt = 0
    while True:
        if(len(node.children)>0 and cnt < len(node.children) and node.children[cnt].nodeType == 'InheritanceSpecifier'):
            if cnt == 0:
                codestr += ' is'
            else:
                codestr += ' ,'
            tmpChildren = node.children[cnt].children
            for item in tmpChildren:
                codestr += ' ' + item.attributes['name']
            cnt+=1
        else:
            break

    codestr += ' {\n\t'
    for i in range(cnt, len(node.children)):
        codestr += switchHandler(node.children[i])
        if node.children[i].nodeType == 'VariableDeclaration':
            codestr += ';\n\t'
    codestr += '\n}'
    return codestr

def variableDecHandler(node):
    # naive declaration
    attributes = node.attributes
    childNodes = node.children
    codestr = ''

    if len(childNodes) == 0:
        codestr += 'var '
        codestr += attributes['name']
    else:
        # naive declaration
        child = node.children[0]
        
        if child.nodeType == 'Mapping':
            codestr += switchHandler(child) + ' '
        elif child.nodeType == 'ArrayTypeName':
            codestr += switchHandler(child) + ' '
        else:
            codestr += child.attributes['name'] + ' '

        if 'indexed' in attributes.keys() and attributes['indexed']:
            codestr += 'indexed '

        if 'visibility' in attributes.keys() and attributes['visibility'] != 'internal':
            codestr += attributes['visibility'] + ' '

        if 'constant' in attributes.keys() and attributes['constant']:
            codestr += 'constant' + ' '
        
        if 'storageLocation' in attributes.keys() and attributes['storageLocation'] == 'memory':
            codestr += 'memory' + ' '
        elif 'storageLocation' in attributes.keys() and attributes['storageLocation'] == 'storage':
            codestr += 'storage' + ' '

        codestr += attributes['name']

        # initialization
        if len(childNodes) > 1:
            codestr += ' = '
            codestr += switchHandler(childNodes[1])

    return codestr

def functionDefHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = ''
    if 'isConstructor' in attributes.keys() and attributes['isConstructor']:
        codestr += 'constructor('
        codestr += switchHandler(childNodes[0])
        codestr += ') '
    else:
        codestr += 'function ' + attributes['name'] + '('
        codestr += switchHandler(childNodes[0])
        codestr += ') '

    # modifiers
    cnt = 2
    if len(childNodes) > 2: 
        while True:
            curNode = childNodes[cnt]
            if(curNode.nodeType == 'ModifierInvocation'):
                codestr += switchHandler(curNode) + ' '
                cnt+=1
            else:
                break
    
    
    if 'stateMutability' in attributes.keys() and attributes['stateMutability'] != 'nonpayable':
        codestr += attributes['stateMutability'] + ' '
    codestr += attributes['visibility'] + ' '
    
    # judge whether it needs 'return'
    if len(childNodes[1].children) > 0:
        codestr += 'returns(' 
        codestr += switchHandler(childNodes[1])
        codestr += ')'
    
    if len(childNodes) > 2: 
        codestr += '{\n\t'
        for i in range(cnt, len(childNodes)):
            codestr += switchHandler(childNodes[i])
        codestr += '}\n\t'
    # function not implemented
    else:
        codestr += ';'
    return codestr

def blockHandler(node):
    codestr = ''
    for item in node.children:
        codestr += switchHandler(item)
    return codestr

def expStatementHandler(node):
    codestr = ''
    for item in node.children:
        codestr += switchHandler(item)
    codestr += ';\n\t'
    return codestr

def assignmentHandler(node):
    attributes = node.attributes
    codestr = ''
    codestr += switchHandler(node.children[0]) + ' '
    codestr += attributes['operator'] + ' '
    codestr += switchHandler(node.children[1])
    return codestr

def identifierHandler(node):
    return node.attributes['value']

def literalHandler(node):
    attributes = node.attributes
    literal = attributes['value']
    if literal == None:
        literal = 'hex"' + attributes['hexvalue'] + '"' 
    else:
        if attributes['token'] == 'string':
            literal = '"' + literal + '"'
        
        if 'subdenomination' in attributes.keys() and attributes['subdenomination']:
            literal += ' ' + attributes['subdenomination']

    return literal

def memberAccessHandler(node):
    attributes = node.attributes
    codestr = ''
    codestr += switchHandler(node.children[0])
    codestr += '.' + attributes['member_name']
    return codestr

def returnHandler(node):
    codestr = ''
    codestr += 'return '

    if(len(node.children) > 0):
        codestr += switchHandler(node.children[0])
    
    codestr += ';\n\t'
    return codestr

def parameterListHandler(node):
    childNodes = node.children
    if(len(childNodes) == 0):
        return ''

    codestr = ''
    for i in range(len(childNodes)-1):
        codestr += switchHandler(childNodes[i]) + ', '
    codestr += switchHandler(childNodes[len(childNodes)-1])
    return codestr

def eventDefHandler(node):
    codestr = 'event '
    attributes = node.attributes
    childNodes = node.children
    codestr += attributes['name'] + '('
    # paramter
    codestr += switchHandler(childNodes[0])
    codestr += ');\n\t'
    return codestr 

def funcCallHandler(node):
    codestr = ''
    childNodes = node.children
    # function name
    codestr += switchHandler(childNodes[0]) + '('
    if len(childNodes) > 1:
        for i in range(1, len(childNodes)-1):
            codestr += switchHandler(childNodes[i]) + ', '
        codestr += switchHandler(childNodes[len(childNodes)-1])
    codestr += ')'
    return codestr

def binaryOpHandler(node):
    attributes = node.attributes
    codestr = ''
    codestr += switchHandler(node.children[0]) + ' '
    codestr += attributes['operator'] + ' '
    codestr += switchHandler(node.children[1])
    return codestr

def modifierDefHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = 'modifier '
    codestr += attributes['name']
    
    codestr += '('
    codestr += switchHandler(childNodes[0])
    codestr += ')'

    codestr += '{\n\t'
    codestr += switchHandler(childNodes[1])
    codestr += '}\n\t'
    return codestr

def conditionalHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = ''
    codestr += switchHandler(childNodes[0])
    codestr += '?'
    codestr += switchHandler(childNodes[1])
    codestr += ':'
    codestr += switchHandler(childNodes[2])
    return codestr

def phStatementHandler(node):
    return  '_;'

def ifStatementHandler(node):
    childNodes = node.children
    codestr = ''
    codestr += 'if('
    codestr += switchHandler(childNodes[0])
    codestr += '){\n\t'

    # if
    # for i in range(1, len(childNodes)):
    codestr += switchHandler(childNodes[1])
    codestr += '}\n\t'

    # else 
    if len(childNodes) > 2:
        codestr += 'else{\n\t'
        codestr += switchHandler(childNodes[2])
        codestr += '}\n\t'
    return codestr

def throwHandler(node):
    return 'throw;'

def unaryOpHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = ''
    if attributes['prefix']:
        codestr += attributes['operator'] + ' '
    codestr += switchHandler(childNodes[0])

    if not attributes['prefix']:
        codestr += attributes['operator']
    return codestr

def modifierInvHandler(node):
    childNodes = node.children
    codestr = ''
    codestr += childNodes[0].attributes['value']
    if len(childNodes) > 1:
        codestr += '('
        for i in range(1, len(childNodes)-1):
            codestr += switchHandler(childNodes[i]) + ','
        codestr += switchHandler(childNodes[len(childNodes)-1])
        codestr += ')'
    return codestr

def indexAccessHandler(node):
    childNodes = node.children
    codestr = ''
    codestr += switchHandler(childNodes[0])
    codestr += '['
    codestr += switchHandler(childNodes[1])
    codestr += ']'
    return codestr

def structDefHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = ''
    codestr += 'struct ' + attributes['name'] + '{\n\t'
    for child in childNodes:
        codestr += switchHandler(child) + ';\n\t'
    codestr += '}\n\t'
    return codestr

def varDecStatementHandler(node):
    childNodes = node.children
    codestr = ''

    deccnt = 0
    for item in childNodes:
        if item.nodeType == 'VariableDeclaration':
            deccnt += 1
    
    template = switchHandler(childNodes[0]).split(' ')
    for i in range(len(template)-1):
        codestr += template[i] + ' '

    if deccnt > 1:
        codestr += '('
        for i in range(deccnt-1):
            codestr += switchHandler(childNodes[i]).split(' ')[-1] + ', '
        codestr += switchHandler(childNodes[deccnt-1]).split(' ')[-1] + ')'
    else:
        codestr += switchHandler(childNodes[0]).split(' ')[-1]
    
    if len(childNodes) != deccnt:
        codestr += ' = '
        codestr += switchHandler(childNodes[deccnt])
    codestr += ';\n\t'
    return codestr

def eleTypeNameExpHandler(node):
    return node.attributes['value']

def forStatementHandler(node):
    childNodes = node.children
    codestr = 'for('
    cnt = 0
    if childNodes[cnt].nodeType ==  'VariableDeclarationStatement' or childNodes[cnt].nodeType == 'ExpressionStatement':
        codestr += switchHandler(childNodes[cnt]).split(';')[0] + ';'
        cnt += 1
    else:
        codestr += ';'
    
    if childNodes[cnt].nodeType ==  'BinaryOperation':
        codestr += switchHandler(childNodes[cnt]) + ';'
        cnt += 1
    else:
        codestr += ';'

    if childNodes[cnt].nodeType ==  'ExpressionStatement':
        codestr += switchHandler(childNodes[cnt]).split(';')[0] + '){\n\t'
        cnt += 1
    else:
        codestr += ';'


    codestr += switchHandler(childNodes[cnt]) + '}\n\t'
    return codestr

def emitStatementHandler(node):
    childNodes = node.children
    codestr = 'emit '
    for item in childNodes:
        codestr += switchHandler(item) + ';\n\t'
    return codestr

def tupleExpHandler(node):
    codestr = ''
    attributes = node.attributes
    childNodes = node.children
    if len(childNodes) == 0:
        # template = attributes['type'].replace('(', '').replace(')', '')
        codestr += '('
        # template.split(',')
        components = attributes['components']
        for i in range(len(components)-1):
            if components[i] != None:
                codestr += components[i]['attributes']['value'] + ','
            else:
                codestr += ','
        codestr += components[len(components)-1]['attributes']['value'] + ')'
        return codestr

    if node.attributes['isInlineArray']:
        codestr += '['
        if(len(childNodes) > 0):
            codestr += switchHandler(childNodes[0])
            for i in range(1, len(childNodes)):
                codestr += ',' + switchHandler(childNodes[i])
        codestr += ']'
    else:
        codestr += '('
        if(len(childNodes) > 0):
            codestr += switchHandler(childNodes[0])
            for i in range(1, len(childNodes)):
                codestr += ',' + switchHandler(childNodes[i])
        codestr += ')'
    return codestr

def newExpHandler(node):
    codestr = 'new '
    child = node.children[0]
    codestr += switchHandler(child)
    return codestr

def whileStatementHandler(node):
    codestr = ''
    childNodes = node.children
    codestr += 'while('
    codestr += switchHandler(childNodes[0]) + '){\n\t'
    codestr += switchHandler(childNodes[1]) 
    codestr += '}\n\t'
    return codestr

def inlineAssemblyHandler(node):
    codestr = 'assembly'
    attributes = node.attributes
    codestr += attributes['operations']
    return codestr

def usingforDirectiveHandler(node):
    codestr = ''
    childNodes = node.children
    codestr += 'using '
    codestr += switchHandler(childNodes[0]) + ' '
    if len(childNodes) > 1:
        codestr += 'for '
        codestr += switchHandler(childNodes[1])
    else:
        codestr += 'for *'
    codestr += ';\n\t'
    return codestr

def userDefTypeNameHandler(node):
    return node.attributes['name']

def elementaryTypeNameHandler(node):
    return node.attributes['name']

def enumDefHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = ''
    codestr += 'enum ' + attributes['name'] + '{\n\t'
    for i in range(0, len(childNodes)-1):
        codestr += childNodes[i].attributes['name'] + ',\n\t'
    codestr += childNodes[len(childNodes)-1].attributes['name']
    codestr += '}\n\t'
    return codestr

def mappingHandler(node):
    attributes = node.attributes
    childNodes = node.children
    codestr = ''
    codestr += 'mapping(' + switchHandler(childNodes[0]) + ' => ' + switchHandler(childNodes[1]) + ')'
    return codestr

def arrayTypeHandler(node):
    attributes = node.attributes
    childNodes = node.children

    codestr = ''
    codestr += childNodes[0].attributes['name'] + '['
    if len(childNodes) > 1:
        codestr += switchHandler(childNodes[1])
    codestr +=']'
    return codestr

# # fake entry of this program
# def main():
#     generatePath = '../compileRes/TSE/'
#     outputPath = '/home/chaoweilanmao/Desktop/tmp/TSE/'
#     astlist = os.listdir(generatePath)
#     for item in astlist:
#         print()
#         print(item)
#         try:
#             treeRoot = generateAST(generatePath + item)
#             # here is about how to modify the AST to repair the defects
#             code = regenerateCode(treeRoot)
#             # print(code)
#             fd = open(outputPath + item.split('.')[0] + '.sol', 'w+')
#             fd.write(code)
#             fd.close()
#         except:
#             print('error')

# treeRoot = generateAST(generatePath + '0x49516fe7bdc54b29a7f95ff55fdd38d9228e55af.ast')
# code = regenerateCode(treeRoot)
# print(code)
    
        
# # test the functions
# if __name__ == "__main__":
#     main()
#     exit(0)
