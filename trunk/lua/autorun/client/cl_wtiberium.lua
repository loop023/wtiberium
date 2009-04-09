killicon.Add("wtib_missile","killicons/wtib_missile_killicon",Color(255,80,0,255))

WTib_NoDynamicLight = false
WTib_DynamicLightSize = 1

function WTib_DynamicLightConsole(ply,com,args)
	if !args[1] then
		WTib_NoDynamicLight = !WTib_NoDynamicLight
	else
		if args[1] == 0 then
			WTib_NoDynamicLight = false
		else
			WTib_NoDynamicLight = true
		end
	end
	if WTib_NoDynamicLight then
		LocalPlayer():ChatPrint("Dynamic lights disabled!")
	else
		LocalPlayer():ChatPrint("Dynamic lights enabled!")
	end
end
concommand.Add("WTiberium_NoDynamicLights",WTib_DynamicLightConsole)

function WTib_DynamicLightsSizeConsole(ply,com,args)
	if !args[1] then
		print("Please specify the size!")
		return
	end
	WTib_DynamicLightSize = tonumber(args[1])
	LocalPlayer():ChatPrint("Dynamic lights size changed to "..tostring(WTib_DynamicLightSize))
end
concommand.Add("WTiberium_DynamicLightsSize",WTib_DynamicLightsSizeConsole)
