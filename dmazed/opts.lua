
-- the displayed name
title="D maze D"


-- the internal name, used for the base game module
name="dmazed"


smells={} -- settings for special smells

smells.dimeload={

	android_package="com.wetgenes."..name..".dimeload",

}

smells.gamestick={

--	android_package="com.playjam.servicesamples",
--	android_activity="com.playjam.servicesamples.MainActivity",


	android_package="com.wetgenes."..name..".gamestick",
	android_activity="com.wetgenes.feralactivity.GameStick",

--	android_package="com.example.stest",

	
	
	android_permissions=[[
<uses-permission android:name="com.playjam.gamestick.permission.DOWNLOAD_SERVICE"/>
<uses-permission android:name="com.playjam.gamestick.permission.DATABASE_INTERFACE_SERVICE"/>
]],


}
