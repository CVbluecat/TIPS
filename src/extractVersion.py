# I want to extract the solc version from smart contract automately
# If users provide the version is better
# I met some condition that the version info is missing in the contract

import sys
import os

if len(sys.argv) < 2:
    print('too little arguments!')

filepath = sys.argv[1]
fd = open(filepath)
content = fd.read().split('\n')
versionWord = ""

for item in content:
    if("pragma" in item and "solidity" in item):
        versionWord = item
        break

versionInfo = versionWord.split(' ')
print(versionInfo)
version = ""
# determinied version in pragma
# example: 0.4.25
if '^' not in versionInfo[2] and '>' not in versionInfo and '<' not in versionInfo:
    version = versionInfo[2].split(';')[0]

# example1: ^0.5.0
# exapmle2: >(=)0.5.0
elif '^' in versionInfo[2] or ('>' in versionInfo[2] and len(versionInfo) == 3):
    # version = versionInfo[2][1:-2]
    label = versionInfo[2].split('.')[1]
    if label == '4':
        version = '0.4.26'
    elif label == '5':
        version = '0.5.15'
    elif label == '6':
        version = '0.6.11'
    elif label == '7':
        version = '0.7.6'

# example: >(=)0.5.0 <(=)0.6.0
# cannot guarantee the correntness, i find some 'pragma' writing like this
# however i haven't met
else:
    label = ''
    if '>' in versionInfo[2]:
        label = versionInfo[2].split('.')[1]
    else:
        label = versionInfo[3].split('.')[1]
    if label == '4':
        version = '0.4.26'
    elif label == '5':
        version = '0.5.15'
    elif label == '6':
        version = '0.6.11'
    elif label == '7':
        version = '0.7.6'

os.system('npm install solc@'+version)