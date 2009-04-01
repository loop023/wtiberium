if SERVER then
	AddCSLuaFile("autorun/wtiberium.lua")

	--Models
	resource.AddFile("models/props_gammarays/tiberium.mdl")
	resource.AddFile("models/props_gammarays/tiberium01.mdl")
	resource.AddFile("models/props_gammarays/tiberium05.mdl")
	resource.AddFile("models/props_gammarays/tiberiumtower5.mdl")
	--Materials
	resource.AddFile("materials/killicons/wtib_missile_killicon.vmt")
	--Sounds
	resource.AddFile("sound/wtiberium/refinery/ref.wav")

	WTib_MaxProductionAmount = 3
	WTib_MinProductionRate = 30
	WTib_MaxProductionRate = 60
	WTib_MaxTotalTiberium = 0
	WTib_TiberiumEntitiesCount = 0
	local WTib_RD3 = false

	function WTib_MaxProductionRateConsole(ply,com,args)
		if !ply:IsAdmin() then
			ply:ChatPrint("This command is admin only "..ply:Nick())
			return
		end
		WTib_MaxProductionRate = math.Clamp(args[1],WTib_MinProductionRate+1,100000)
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MaxProductionRate)
		end
	end
	concommand.Add("WTiberium_MaxProductionRate",WTib_MaxProductionRateConsole)

	function WTib_MinProductionRateConsole(ply,com,args)
		if !ply:IsAdmin() then
			ply:ChatPrint("This command is admin only "..ply:Nick())
			return
		end
		WTib_MinProductionRate = math.Clamp(args[1],20,WTib_MaxProductionRate-1)
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MinProductionRate)
		end
	end
	concommand.Add("WTiberium_MinProductionRate",WTib_MinProductionRateConsole)

	function WTib_MaxProductionsConsole(ply,com,args)
		if !ply:IsAdmin() then
			ply:ChatPrint("This command is admin only "..ply:Nick())
			return
		end
		WTib_MaxProductionRate = math.Clamp(args[1],1,50)
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MaxProductionRate)
		end
	end
	concommand.Add("WTiberium_MaxProductions",WTib_MaxProductionsConsole)

	function WTib_MaxTotalTiberiumConsole(ply,com,args)
		if !ply:IsAdmin() then
			ply:ChatPrint("This command is admin only "..ply:Nick())
			return
		end
		WTib_MaxTotalTiberium = args[1]
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint("Maximum tiberium entities has changed to "..WTib_MaxTotalTiberium)
		end
	end
	concommand.Add("WTiberium_MaxTotalTiberium",WTib_MaxTotalTiberiumConsole)

	function WTib_GetAllTiberium()
		local a = {}
		for _,v in pairs(ents.GetAll()) do
			if v.IsTiberium then
				table.insert(a,v)
			end
		end
		return a
	end


	function WTib_IsRD3()
		if WTib_RD3 then return WTib_RD3 end
		if CAF and CAF.GetAddon("Resource Distribution") and RD then
			WTib_RD3 = true
			return true
		end
		WTib_RD3 = false
		return false
	end

	function WTib_IsRD2()
		return Dev_Unlink_All != nil
	end

	function WTib_SupplyResource(a,b,c)
		if WTib_IsRD3() then
			return RD.SupplyResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_SupplyResource(a,b,c)
		end
	end

	function WTib_ConsumeResource(a,b,c)
		if WTib_IsRD3() then
			return RD.ConsumeResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_ConsumeResource(a,b,c)
		end
	end

	function WTib_AddResource(a,b,c)
		if WTib_IsRD3() then
			return RD.AddResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_AddResource(a,b,c)
		end
	end

	function WTib_GetResourceAmount(a,b,c)
		if WTib_IsRD3() then
			return RD.GetResourceAmount(a,b,c)
		elseif WTib_IsRD2 then
			return RD_GetResourceAmount(a,b,c)
		end
	end

	function WTib_BuildDupeInfo(a)
		if WTib_IsRD3() then
			return RD.BuildDupeInfo(a)
		elseif WTib_IsRD2 then
			return RD_BuildDupeInfo(a)
		end
	end

	function WTib_ApplyDupeInfo(a,b)
		if WTib_IsRD3() then
			return RD.ApplyDupeInfo(a,b)
		elseif WTib_IsRD2 then
			return RD_ApplyDupeInfo(a,b)
		end
	end

elseif CLIENT then

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

end

function WTib_PhysPickup(ply,ent)
	if ent.IsTiberium then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_PhysPickup",WTib_PhysPickup)
