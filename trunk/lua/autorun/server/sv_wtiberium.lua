
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
local RD3
local RD

if WDS then
	WDS.AddProtectionFunction(function(ent)
		if ent.IsTiberium then
			return false
		end
	end)
end

function WTib_MaxProductionRateConsole(ply,com,args)
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxProductionRate = math.Clamp(tonumber(args[1]),tonumber(WTib_MinProductionRate)+1,100000)
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
	WTib_MinProductionRate = math.Clamp(tonumber(args[1]),1,tonumber(WTib_MaxProductionRate)-1)
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
	WTib_MaxProductionRate = math.Clamp(tonumber(args[1]),1,50)
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
	WTib_MaxTotalTiberium = tonumber(args[1])
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium entities has changed to "..WTib_MaxTotalTiberium)
	end
end
concommand.Add("WTiberium_MaxTotalTiberium",WTib_MaxTotalTiberiumConsole)

function WTib_ClearAllTiberiumConsole(ply,com,args)
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	local a = 0
	for _,v in pairs(WTib_GetAllTiberium()) do
		if v and v:IsValid() then
			v:Remove()
			a = a+1
		end
	end
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Removed all "..tostring(a).." tiberium entities!")
	end
end
concommand.Add("WTiberium_ClearAllTiberium",WTib_ClearAllTiberiumConsole)

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

function WTib_RagdollToTiberium(rag)
	if !rag or !rag:GetClass() == "prop_ragdoll" then return NULL end
	rag.WTib_OldCollisionGroup = rag:GetCollisionGroup()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag.IsTiberium = true
	rag.SetTiberiumAmount = function(self,am)
		self:SetNWInt("TiberiumAmount",math.Clamp(am,-10,self.MaxTiberium))
		if self:GetNWInt("TiberiumAmount") <= 0 then
			WTib_TiberiumRagdollToRagdoll(self)
			return
		end
	end
	rag.AddTiberiumAmount = function(self,am)
		self:SetTiberiumAmount(math.Clamp(self:GetTiberiumAmount()+am,-10,self.MaxTiberium))
	end
	rag.DrainTiberiumAmount = function(self,am)
		self:SetTiberiumAmount(math.Clamp(self:GetTiberiumAmount()-am,-10,self.MaxTiberium))
	end
	rag.GetTiberiumAmount = function(self)
		return self:GetNWInt("TiberiumAmount")
	end
	rag.FunctionToRunOnNormal		= func
	rag.TiberiumDraimOnReproduction	= 0
	rag.MinReprodutionTibRequired	= 0
	rag.RemoveOnNoTiberium			= false
	rag.DisableAntiPickup			= true
	rag.ReproductionRate			= 0
	rag.MinTiberiumGain				= 0
	rag.MaxTiberiumGain				= 0
	rag.ShouldReproduce				= false
	rag.ReproduceDelay				= 0
	rag.TiberiumAdd					= false
	rag.MaxTiberium					= 700
	rag.DynLight					= false
	rag.Gas							= false
	rag.r							= 0
	rag.g							= 255
	rag.b							= 0
	rag.a							= 150
	rag:SetTiberiumAmount(700)
	rag:SetColor(rag.r,rag.g,rag.b,rag.a)
	rag:GetTable().WTib_StatueInfo = {}
	rag:GetTable().WTib_StatueInfo.Welds = {}
	local bones = rag:GetPhysicsObjectCount()
	for bone=1, bones do
		local bone1 = bone-1
		local bone2 = bones-bone
		if (!rag:GetTable().WTib_StatueInfo.Welds[bone2]) then
			local weld1 = constraint.Weld(rag,rag,bone1,bone2,0)
			if (weld1) then
				rag:GetTable().WTib_StatueInfo.Welds[bone1] = weld1
			end
		end
		local weld2 = constraint.Weld(rag,rag,bone1,0,0)
		if (weld2) then
			rag:GetTable().WTib_StatueInfo.Welds[bone1+bones] = weld2
		end
		local ed = EffectData()
		ed:SetOrigin(rag:GetPhysicsObjectNum(bone1):GetPos())
		ed:SetScale(1)
		ed:SetMagnitude(1)
		util.Effect("GlassImpact",ed,true,true)
	end
	return rag
end

function WTib_TiberiumRagdollToRagdoll(rag,func)
	if !rag or !rag:GetClass() == "prop_ragdoll" or !rag.IsTiberium then return NULL end
	rag:SetCollisionGroup(rag.WTib_OldCollisionGroup)
	rag.TiberiumDraimOnReproduction	= nil
	rag.MinReprodutionTibRequired	= nil
	rag.WTib_OldCollisionGroup		= nil
	rag.DrainTiberiumAmount			= nil
	rag.RemoveOnNoTiberium			= nil
	rag.SetTiberiumAmount			= nil
	rag.AddTiberiumAmount			= nil
	rag.DisableAntiPickup			= nil
	rag.GetTiberiumAmount			= nil
	rag.ReproductionRate			= nil
	rag.MinTiberiumGain				= nil
	rag.MaxTiberiumGain				= nil
	rag.ShouldReproduce				= nil
	rag.ReproduceDelay				= nil
	rag.TiberiumAdd					= nil
	rag.MaxTiberium					= nil
	rag.IsTiberium					= nil
	rag.DynLight					= nil
	rag.Gas							= nil
	rag.r							= nil
	rag.g							= nil
	rag.b							= nil
	rag.a							= nil
	rag:SetColor(255,255,255,255)
	for _,v in pairs(rag:GetTable().WTib_StatueInfo.Welds) do
		if v and v:IsValid() then
			v:Remove()
		end
	end
	rag:GetTable().WTib_StatueInfo = nil
	if rag.FunctionToRunOnNormal and type(rag.FunctionToRunOnNormal) == "function" then
		rag.FunctionToRunOnNormal(rag)
	end
	return rag
end

/*
	***************************************************
	*  RD3 and RD2 shit down here, these are all placeholders   *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_IsRD3()
	if(RD3 ~= nil) then return RD3 end
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		RD3 = true
		RD = CAF.GetAddon("Resource Distribution")
		return true
	end
	RD3 = false
	return false
end

function WTib_HasRD()
	return (Dev_Link != nil or #file.FindInLua("weapons/gmod_tool/stools/dev_link.lua") == 1)
end

function WTib_IsRD2()
	if WTib_IsRD3() then return false end
	return (Dev_Unlink_All != nil)
end

function WTib_SupplyResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.SupplyResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_SupplyResource(a,b,c)
		end
	end
end

function WTib_ConsumeResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.ConsumeResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_ConsumeResource(a,b,c)
		end
	end
end

function WTib_AddResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.AddResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_AddResource(a,b,c)
		end
	end
end

function WTib_GetResourceAmount(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.GetResourceAmount(a,b,c)
		elseif WTib_IsRD2 then
			return RD_GetResourceAmount(a,b,c)
		end
	end
end

function WTib_RemoveRDEnt(a)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.RemoveRDEntity(a)
		elseif Dev_Unlink_All and a.resources2links then
			return Dev_Unlink_All(a)
		end
	end
end

function WTib_GetNetworkCapacity(a,b)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.GetNetworkCapacity(a,b)
		elseif WTib_IsRD2 then
			return RD_GetNetworkCapacity(a,b)
		end
	end
end

function WTib_BuildDupeInfo(a)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.BuildDupeInfo(a)
		elseif WTib_IsRD2 then
			return RD_BuildDupeInfo(a)
		end
	end
end

function WTib_ApplyDupeInfo(a,b)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.ApplyDupeInfo(a,b)
		elseif WTib_IsRD2 then
			return RD_ApplyDupeInfo(a,b)
		end
	end
end

function WTib_RegisterEnt(a,b)
	if LS_RegisterEnt then
		return LS_RegisterEnt(a,b)
	end
end
