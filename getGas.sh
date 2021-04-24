#! /bin/bash

cnt=0
# path="/home/chaoweilanmao/Desktop/nextResearch/ARSC/repairRes/scsc/"
path="/home/chaoweilanmao/Desktop/nextResearch/ARSC/repairRes/TSE/"
# path="/home/chaoweilanmao/Desktop/tmp/"
# for item in `ls ./repairRes/scsc/`
for item in `ls ./repairRes/TSE/`
# for item in `ls /home/chaoweilanmao/Desktop/tmp/`
do
    echo $item
    python ./src/extractVersion.py ${path}${item}

    node ./src/computeGas.js ${item}
    ((cnt+=1))
done