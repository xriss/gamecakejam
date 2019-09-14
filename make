cd `dirname $0`

rm cakes/*.cakes

cakes="gateau aroids batwsbat cloids dmazed gagano gthang hunted lemonhunter lonelybird macrl quip umon"

for cake in ${cakes} ; do

	cd ${cake}

	echo ${cake}

	gamecake bake.lua
	cp out/${cake}.zip ../cakes/${cake}.cake

	cd ..
done

