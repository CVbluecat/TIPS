#! /bin/bash


path=$1
outputpath=$2
cnt=0
# path="/home/chaoweilanmao/Desktop/nextResearch/ARSC/contractSource/TSE/"
# path="/home/chaoweilanmao/Desktop/nextResearch/ARSC/contractSource/SmartBug/"
# path="/home/chaoweilanmao/Desktop/nextResearch/ARSC/contractSource/test/"
# path="/home/chaoweilanmao/Desktop/tmp/"
# for item in `ls ./contractSource/TSE/`
# for item in `ls ./contractSource/SmartBug/`
for item in `ls ${path}`
# for item in `ls /home/chaoweilanmao/Desktop/tmp/`
do
    echo $item
    python ./src/extractVersion.py ${path}${item}

    node ./src/compile.js ${path} ${item} ${outputpath}
    ((cnt+=1))
done