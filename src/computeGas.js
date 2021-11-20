const solc = require('solc')
const fs = require('fs')
const shelljs = require('shelljs')
// const sourcePath = './contractSource/test/'
const sourcePath = '/home/chaoweilanmao/Desktop/tmp/'
const outputPath = './compileRes/TSE/'

// let fileidx = parseInt(process.argv.splice(2)[0])
let fileidx = process.argv.splice(2)[0]
let files = fs.readdirSync(sourcePath)

// The solc version after 0.5.0, we need a template to finish the compilation
// you can see the question in https://ethereum.stackexchange.com/questions/63267/solc-compile-0-5-0-is-not-working-like-0-4-version
let inputTemplate = 
{
    language: 'Solidity',
    sources: {
    },
    settings: {
        outputSelection: {
            "*": {
              "*" : [],
              "": ["legacyAST"]
            }
          }
    }
};

console.log(fileidx)
// let codePath = sourcePath + files[fileidx]
let codePath = sourcePath + fileidx
console.log(codePath)
let codeContent = fs.readFileSync(codePath, 'UTF-8').toString()
let version = solc.version().toString().split('+')[0].split('.')[1]
// discriminate the version of solc
if(version !== '4') {
  inputTemplate.sources[files[fileidx]] = {}
  inputTemplate.sources[files[fileidx]]['content'] = codeContent
  try {
    // console.log(inputTemplate)
    let output = JSON.parse(solc.compile(JSON.stringify(inputTemplate)));
    // console.log(output['contracts'].keys())
    console.log(output)
    // fs.writeFileSync(outputPath+files[fileidx].split('.')[0]+'.ast', JSON.stringify(output['sources'][files[fileidx]]['legacyAST']))
  } catch(e) {
    console.log(e.toString())
  }
} else {
  try {
    // console.log(codeContent)
    let output = solc.compile(codeContent, (res)=>{})
    let gasUsed = 0;
    for(key in output['contracts']){
        let gas_em = output['contracts'][key]['gasEstimates']
        let creation = gas_em['creation']
        let external = gas_em['external']
        let internal = gas_em['internal']
        
        for(gas in creation) {
            gasUsed += Number(creation[gas]);
        }

        for(func in external) {
            if(external[func]) {
                gasUsed += Number(external[func])
            }
        }

        for(func in internal) {
            if(internal[func]) {
                gasUsed += Number(internal[func])
            }
        }
    }
    console.log(gasUsed)
    // fs.writeFileSync(outputPath+files[fileidx].split('.')[0]+'.ast', JSON.stringify(output['sources']['']['AST']))
  } catch(e) {
    console.log(e.toString())
  }
}
