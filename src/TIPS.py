from generateAST import generateAST, regenerateCode
from model.unchecked_call import repair_unchecked_call1, repair_unchecked_call2
from model.reentrancy import repair_reentrancy1, repair_reentrancy2
from model.arithmetic import repair_arithmetic
from model.access_control import repair_access_control
from model.unused_state import repair_unused_state
from model.strict_balance import repair_strict_balance
from model.unmatched_type import repair_unmatched_type
from model.misleading_dataloc import repair_misleading_dataloc
from model.hard_encode import repair_hard_encode
from model.missing_interrupter import repair_missing_interrupter

import os
import json
import time
import copy
import getopt
import sys

def switchCategory(defect, astPath, codePath):
    name = defect['name']
    print(name)
    defect = defect['defect']
    astfile = astPath + name.split('.')[0] + '.ast'
    fd = open(astfile)
    astcontent = fd.read()
    fd.close()
    aststruct = generateAST(astcontent) # ast inline structure
    astpool = [aststruct]
    namepool = [name]
    codepool = []

    # Newline translation disabled
    codefd = open(codePath + name, 'r', newline='', encoding='UTF-8')
    codecontent = codefd.read().split('\n')
    codefd.close()
    
    for item in defect:
        category = item['category']
        lineno = item['lines']
        for i in range(len(lineno)):
            # begin number of the character
            lineno[i] = lineToChar(codecontent, lineno[i])
        
        tmppool = []
        tmpnamepool = []
        for curast in astpool:
            if category == 'arithmetic':
                repair_arithmetic(curast, lineno)
                continue
            elif category == 'access_control':
                repair_access_control(curast, lineno)
                continue
            elif category == 'time_manipulation':
                pass
            elif category == 'greedy' or category == 'missing_interrupter':
                repair_missing_interrupter(curast, lineno)
                continue
            elif category == 'missing_reminder':
                pass
            elif category == 'unused_state':
                repair_unused_state(curast, lineno)
                continue
            elif category == 'misleading_dataloc':
                repair_misleading_dataloc(curast, lineno)
                continue
            elif category == 'hard_encode':
                repair_hard_encode(curast, lineno)
                continue
            elif category == 'unmatched_type':
                repair_unmatched_type(curast, lineno)
                continue
            elif category == 'strict_balance':
                repair_strict_balance(curast, lineno)
                continue
            else:
                pass

            if category == 'reentrancy':
                idx = astpool.index(curast)
                name = namepool[idx]
                ast1 = copy.deepcopy(curast)
                ast2 = copy.deepcopy(curast)
                repair_reentrancy1(ast1, lineno)
                repair_reentrancy2(ast2, lineno)
                tmppool.append(ast1)
                tmppool.append(ast2)
                tmpnamepool.append(name.split('.')[0] + 'R1.sol')
                tmpnamepool.append(name.split('.')[0] + 'R2.sol')
            
            if category == 'unchecked_low_level_calls':
                idx = astpool.index(curast)
                name = namepool[idx]
                ast1 = copy.deepcopy(curast)
                ast2 = copy.deepcopy(curast)
                repair_unchecked_call1(ast1, lineno)
                repair_unchecked_call2(ast2, lineno)
                tmppool.append(ast1)
                tmppool.append(ast2)
                tmpnamepool.append(name.split('.')[0] + 'U1.sol')
                tmpnamepool.append(name.split('.')[0] + 'U2.sol')

        if category == 'reentrancy' or category == 'unchecked_low_level_calls':
            astpool = tmppool
            namepool = tmpnamepool
    for item in astpool:
        codepool.append(regenerateCode(item))
    return namepool, codepool

def lineToChar(code, lineno):
    charcnt = 0
    for i in range(lineno-1):
        charcnt += len(code[i].encode()) + 1

    j = 0
    while j < len(code[lineno-1]):
        if code[lineno-1][j] != ' ' and code[lineno-1][j] != '\t':
            break
        else:
            charcnt+=1
        j+=1
    return charcnt

def main():
    # defect list path
    defectListPath = '../defectList/'
    astPath = '../compileRes/'
    codePath = '../contractSource/'
    outputPath = '../repairRes/'

    opts,args = getopt.getopt(sys.argv[1:],'i:o:a:d:')
    for opt, arg in opts:
        if opt == '-a':
            astPath = arg
        elif opt == '-d':
            defectListPath = arg
        elif opt == '-i':
            codePath = arg
        elif opt == '-o':
            outputPath = arg

    defectList = os.listdir(defectListPath)
    for defectFile in defectList:

        fd = open(defectListPath + defectFile)
        defects = json.loads(fd.read())
        fd.close()
        
        for defect in defects:
            begin = time.clock()
            filename, code = switchCategory(defect, astPath, codePath)
            if code == '':
                continue
            for i in range(len(filename)):
                outputfd = open(outputPath + filename[i], 'w+', encoding='UTF-8')
                outputfd.write(code[i])
                outputfd.close()
            end = time.clock()
            print(end - begin)

if __name__ == "__main__":
    main()
    exit(0)
