cd `dirname $0`

rm cakes/*.cakes

#cakes="gateau gthang lonelybird hunted dmazed"
cakes="lonelybird"

for cake in ${cakes} ; do

	cd ${cake}

	echo ${cake}

	gamecake bake.lua
	cp out/${cake}.zip ../cakes/${cake}.cake

	cd ..
done

