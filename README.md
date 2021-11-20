# TIPS

This is a tool to automatically repair the smarct contracts with vulnerabilities.

## Pre-processing

Before repairing, we need to prepare the defect list file and ast file.

### defect list file

use the slither to automatedly generate the `defectList`, first you need to get the slither with docker.

```
docker pull trailofbits/eth-security-toolbox
```

Then run the docker container like the following:

```
docker run -it -v /Users/aa/go/src/six-days/blockchain:/contract trailofbits/eth-security-toolbox
```

Then in the docker container, run the `exeslither.sh` like the following way, you can generate the detect report by slither in the  `target_dir`:

```
./exeslither.sh contract_dir target_dir
```

Finally use the file `generateDefectList.py` to generate the final `defectList`:

```
python3 generateDefectList.py report_dir contract_dir defectList_dir
```


The defect list file will be put under the directory `defectList`, we should standardize the structure in it, the content is like this:

```
[
    {
        "name": "test.sol",
        "defect": [
            {
                "lines": [
                    8,
                    9
                ],
                "category": "access_control"
            },
            {
                "lines": [
                    12
                ],
                "category": "reentrancy"
            }
        ]
    }
]
```

`name` is the contract name we wanna repair, `defect` is a list to record the information of vulnerabilities, `category` is the sort of the vulnerabilities and `lines` is the location in the contract code.


###  ast file

We also need to get AST of the contract code. To help the users, we just need to run the following command in the ARSC directory:

```
./getAST.sh contract_source_dir output_dir
```

You need to specify the path of contract source code and the path that AST file will be saved for example:

```
./getAST.sh ./contractSource/test/ ./compileRes/test/
```

## repair
To start up the repair procedure, we just run the following commmand:
```
python3 ./src/TIPS.py -d defect_file_dir -a ast_file_dir -i source_code_dir -o output_dir
```
`defect_file_dir` means the directory defect list file saved, `ast_file_dir` represents the output directory of AST file. `source_code_dir` and `output_dir` means the location of original contract and the directory you wanna output the repaired contracts. 
for example we can run:
```
python3 ./src/TIPS.py -i ./contractSource/test/ -a ./compileRes/test/ -d ./defectList/test/ -o ./repairRes/test/
```
