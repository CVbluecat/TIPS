#! /bin/sh
for file in `ls ./contractSource/TSE/`
do
	echo ${file}
	docker run -v /home/chaoweilanmao/Desktop/nextResearch/ARSC/contractSource/TSE/:/contract mythril/myth a /contract/${file} --solv 0.4.25 --execution-timeout 100 -o json -t 3
	echo '\n'
done
