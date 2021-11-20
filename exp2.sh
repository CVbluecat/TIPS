#! /bin/sh
for file in `ls ./repairRes/SmartBug/`
do
	echo ${file}
	docker run -v /home/chaoweilanmao/Desktop/nextResearch/ARSC/repairRes/SmartBug/:/contract mythril/myth a /contract/${file} --solv 0.4.25 --execution-timeout 100 -o json -t 3
	echo '\n'
done
