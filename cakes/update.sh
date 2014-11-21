cd `dirname $0`

rm *.cake

for dir in ../*/ ; do

	echo $dir

	cd $dir
	../bake >/dev/null

	rm  -rf ${dir}out
	rm  -rf ${dir}data

	if [ -d "${dir}out/" ]; then
		for f in ${dir}out/*.zip; do 
			cp $f ../cakes/`basename $f .zip`.cake
		done
	fi

done

