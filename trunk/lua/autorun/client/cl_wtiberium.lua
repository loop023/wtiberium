killicon.Add("wtib_missile","killicons/wtib_missile_killicon",Color(255,80,0,255))

WTIBERIUM_NODYNAMICLIGHT = false
function WTib_DynamicLightConsole(ply,com,args)
	if !args[1] then
		WTIBERIUM_NODYNAMICLIGHT = !WTIBERIUM_NODYNAMICLIGHT
	else
		if args[1] == 0 then
			WTIBERIUM_NODYNAMICLIGHT = false
		else
			WTIBERIUM_NODYNAMICLIGHT = true
		end
	end
	if WTIBERIUM_NODYNAMICLIGHT then
		LocalPlayer():ChatPrint("Dynamic lights disabled!")
	else
		LocalPlayer():ChatPrint("Dynamic lights enabled!")
	end
end
concommand.Add("WTiberium_NoDynamicLights",WTib_DynamicLightConsole)
