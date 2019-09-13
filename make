cd `dirname $0`

rm cakes/*.cakes

cakes="gateau gthang lonelybird hunted dmazed"

for cake in ${cakes} ; do

	cd ${cake}

	echo ${cake}

	../../bake
	cp out/${cake}.zip ../cakes/${cake}.cake

	cd ..
done

