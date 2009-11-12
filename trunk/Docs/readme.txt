
Q/A :
	Q: Those dynamic lights lag my PC, how do i remove it?
	A: Open up your console and type in "WTib_NoDynamicLights 1" (Without the quotation marks), you can also change the size by using "WTib_DynamicLightsSize" (Default 1), more options are located in the menu.

	Q: The tiberium grows to fast/slow!
	A: you can use the commands "WTib_MaxProductionRate" and "WTib_MinProductionRate" to set the spawn rate of the tiberium,
		you can also limit the amount of tiberium entities spawned per entity with the command "WTib_MaxProduction", but the tiberium wont grow super fast just because it is set to the fastest,
		the tiberium still needs to find and open space to place its "offspring", and this takes time.

	Q: What should i use, RD/LS2 or RD/LS3?
	A: WTiberium works with both RD/LS2 and RD/LS3, i recommend RD2/LS2 since RD3/LS3 is still in beta.

	Q: How can i help you?
	A: I am always looking for new/better models, textures and sounds, if you want to know more specific information just PM me on facepunch.

Credits :
	These credits can be outdated, if so please notify me and i'll update the list.
	
	Lynix : For the original tiberium models.
	kevkev : For the rest of the stuff in there.
	NightReaper : Models and icons
	Hoizen : Models
	Sn1per : For some ideas and testing help.

Console commands :
	Serverside :
		WTib_MaxFieldSize - The maximum amount of tiberium per field (Default 50)
		WTib_MaxProductionRate - Growth speed of the tiberium at its maximum (Default 60)
		WTib_MinProductionRate - Growth speed of the tiberium at its minimum (Default 30)
		WTib_ClearAllTiberium - Removes all tiberium entities from the map

	Clientside :
		WTib_DynamicLight - Enables/Disables the dynamic lights on the entities.
		WTib_DynamicLightSize - The size of the dynamic lights when enabled.
		WTib_UseToolTips - If the tiberium tooltips should be enabled.
		WTib_UseOldTooltips - If we should use the classic or the new way of showing the tooltips.
		
	Note that all these commands are in a menu!

Changelog (These changes are incomplete, i do leave out a lot of changes since i am to lazy to note them all) :

	*Changelog is no longer supported, check the changes in the SVN changelog per revision*

	1.13 :
	Tiberium will no longer spawn so close to another tiberium entity,
	Tiberium will no longer attempt to grow upon another piece of tiberium or a player,
	The gas effect of the tiberium sprayer now starts closer,
	Fixed the missile launcher,
	Added balloon tooltips to the tiberium tank and Refined tiberium tank,
	Tiberium now emits gas when removed,
	Tiberium now emits gas when spawned,
	Added a tiberium seeder warhead,
	The tiberium entities will no longer collide with the player,
	The missile now gives more arguments to the warhead,
	Added a sonic grenade,
	Changed the range of the harvester from 200 units to 300 units,
	Added a spark effect for the harvester,
	Added a tiberium chemical plant,
	Fixed the refinery not draining resources,
	Moved all the variables for using the tiberium base to the shared file,
	Added more variables to the tiberium base,
	Added a tiberium prop (Only spawnable with Lua),
	Added the thermonium warhead,
	Added a small, medium and large storage tank of every resource in the tiberium addon,
	Tiberium now properly spawns on props,
	Added a small harvester,

	1.12 :
	Better spawn heights for the entities,
	Added RD3 support (Untested!),

	1.11 :
	Different sizes and colors of gas are now possible,
	Fixed the gas having the wrong color on the blue tiberium,
	Fixed a typo in the gas code,
	Added a way to set the damage of the gas,
	Made the tiberium sprayer use the new functions,

	1.1 :
	Added a power plant that runs on refined tiberium,
	Fixed the tiberium sprayer,
	I now use env_smoketrail for a better looking effect,
	Blue and green tiberium will no longer spawn close to eachother,
	Added a docs folder with some info,
	
	1.0 :
	Initial Release.
