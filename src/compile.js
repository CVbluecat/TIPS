const solc = require('solc')
const fs = require('fs')
const shelljs = require('shelljs')
let args = process.argv.splice(2)
const sourcePath = args[0]
console.log(sourcePath)
// const sourcePath = '/home/chaoweilanmao/Desktop/tmp/'
const outputPath = args[2]

// let fileidx = parseInt(process.argv.splice(2)[0])
let fileidx = args[1]
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
  inputTemplate.sources[fileidx] = {}
  inputTemplate.sources[fileidx]['content'] = codeContent
  try {
    // console.log(inputTemplate)
    let output = JSON.parse(solc.compile(JSON.stringify(inputTemplate)));
    fs.writeFileSync(outputPath+fileidx.split('.')[0]+'.ast', JSON.stringify(output['sources'][files[fileidx]]['legacyAST']))
  } catch(e) {
    console.log(e.toString())
  }
} else {
  try {
    // console.log(codeContent)
    let output = solc.compile(codeContent, (res)=>{})
    fs.writeFileSync(outputPath+fileidx.split('.')[0]+'.ast', JSON.stringify(output['sources']['']['AST']))
  } catch(e) {
    console.log(e.toString())
  }
}
