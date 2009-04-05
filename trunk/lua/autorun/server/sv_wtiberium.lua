
--Models
resource.AddFile("models/props_gammarays/tiberium.mdl")
resource.AddFile("models/props_gammarays/tiberium01.mdl")
resource.AddFile("models/props_gammarays/tiberium05.mdl")
resource.AddFile("models/props_gammarays/tiberiumtower5.mdl")
--Materials
resource.AddFile("materials/killicons/wtib_missile_killicon.vmt")
--Sounds
resource.AddFile("sound/wtiberium/refinery/ref.wav")
resource.AddFile("sound/wtiberium/sonicexplosion/explode.wav")

WTib_MaxProductionAmount = 3
WTib_InfectedLifeForms = {}
WTib_MinProductionRate = 30
WTib_MaxProductionRate = 60
WTib_MaxTotalTiberium = 0
local RD

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

function WTib_PlayerSpawn(ply)
	if WTib_IsInfected(ply) then
		WTib_CureInfection(ply)
	end
end
hook.Add("PlayerSpawn","WTib_PlayerSpawn",WTib_PlayerSpawn)

function WTib_Think()
	local e = WTib_GetAllTiberium()[1] or NULL
	for _,v in pairs(WTib_InfectedLifeForms) do
		if v and v:IsValid() and v:Alive() and (v.WTib_NextInfectedDamage or 0) <= CurTime() then
			v:TakeDamage(1,e,e)
			v.WTib_NextInfectedDamage = CurTime()+2
		end
	end
end
hook.Add("Think","WTib_Think",WTib_Think)

function WTib_GetAllTiberium()
	local a = {}
	for _,v in pairs(ents.GetAll()) do
		if v.IsTiberium then
			table.insert(a,v)
		end
	end
	return a
end

function WTib_InfectLiving(ply)
	if ply and ply:IsValid() and (ply:IsPlayer() or ply:IsNPC()) then
		ply:SetColor(0,200,0,255)
		table.insert(WTib_InfectedLifeForms,ply)
	end
end

function WTib_CureInfection(ply)
	if ply and ply:IsValid() and (ply:IsPlayer() or ply:IsNPC()) then
		for k,v in pairs(WTib_InfectedLifeForms) do
			if v == ply then
				ply:SetColor(255,255,255,255)
				WTib_InfectedLifeForms[k] = nil
			end
		end
	end
end

function WTib_IsInfected(ply)
	return table.HasValue(WTib_InfectedLifeForms,ply)
end

/*
	***************************************************
	*  RD3 and RD2 shit down here, these are all placeholders   *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_IsRD3()
	if RD != nil then return true end
	if (CAF and CAF.GetAddon("Resource Distribution") and WTib_HasRD()) then
		RD = CAF.GetAddon("Resource Distribution")
		return true
	end
	return false
end

function WTib_HasRD()
	return (Dev_Link or #file.FindInLua("weapons/gmod_tool/stools/dev_link.lua") == 1)
end

function WTib_IsRD2()
	if WTib_IsRD3() then return false end
	return (Dev_Unlink_All != nil)
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

function WTib_RemoveRDEnt(e)
	if WTib_IsRD3() then
		RD.RemoveRDEntity(e)
	elseif Dev_Unlink_All and e.resources2links then
		Dev_Unlink_All(e)
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

function WTib_RegisterEnt(a,b)
	if LS_RegisterEnt then
		LS_RegisterEnt(a,b)
	end
end
