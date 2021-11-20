path=$1
output=$2
for item in `ls $path`
do
	echo $item
	slither $path$item --json $output$item.json
done
