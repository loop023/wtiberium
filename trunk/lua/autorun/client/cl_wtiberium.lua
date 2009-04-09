killicon.Add("wtib_missile","killicons/wtib_missile_killicon",Color(255,80,0,255))

WTib_DynamicLight = CreateClientConVar("WTiberium_DynamicLights",1,true,true)
WTib_DynamicLightSize = 1

function WTib_DynamicLightsSizeConsole(ply,com,args)
	if !args[1] then
		print("Please specify the size!")
		return
	end
	WTib_DynamicLightSize = tonumber(args[1])
	LocalPlayer():ChatPrint("Dynamic lights size changed to "..tostring(WTib_DynamicLightSize))
end
concommand.Add("WTiberium_DynamicLightsSize",WTib_DynamicLightsSizeConsole)
