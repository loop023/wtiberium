
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

--Wire Sound emitter sounds
list.Set("WireSounds","GDI - Harvester lost",{wire_soundemitter_sound="wtiberium/gdi/Geva_HarvesterLost.wav"})
list.Set("WireSounds","GDI - Harvester under attack",{wire_soundemitter_sound="wtiberium/gdi/Geva_HarvUndAttack.wav"})
list.Set("WireSounds","GDI - Low power",{wire_soundemitter_sound="wtiberium/gdi/Geva_LowPower.wav"})
list.Set("WireSounds","GDI - Tiberium exposure",{wire_soundemitter_sound="wtiberium/gdi/Geva_TiberExposDet.wav"})
list.Set("WireSounds","GDI - Tiberium weapon ready",{wire_soundemitter_sound="wtiberium/gdi/Geva_TiberWeaReady.wav"})
list.Set("WireSounds","GDI - TIberium field depleted",{wire_soundemitter_sound="wtiberium/gdi/Geva_TibFieldDeple.wav"})
list.Set("WireSounds","NOD - Harvester lost",{wire_soundemitter_sound="wtiberium/nod/Geva_HarvesterLost.wav"})
list.Set("WireSounds","NOD - Harvester under attack",{wire_soundemitter_sound="wtiberium/nod/Neva_HarvUndAttack.wav"})
list.Set("WireSounds","NOD - Low power",{wire_soundemitter_sound="wtiberium/nod/Neva_LowPower.wav"})
list.Set("WireSounds","NOD - Tiberium exposure",{wire_soundemitter_sound="wtiberium/nod/Neva_TiberExposDet.wav"})
list.Set("WireSounds","NOD - Tiberium weapon ready",{wire_soundemitter_sound="wtiberium/nod/Neva_TiberWeaReady.wav"})
list.Set("WireSounds","NOD - TIberium field depleted",{wire_soundemitter_sound="wtiberium/nod/Neva_TibFieldDeple.wav"})
list.Set("WireSounds","Scrin - Harvester lost",{wire_soundemitter_sound="wtiberium/gdi/Aeva_HarvesterLost.wav"})
list.Set("WireSounds","Scrin - Harvester under attack",{wire_soundemitter_sound="wtiberium/gdi/Aeva_HarvUndAttack.wav"})
list.Set("WireSounds","Scrin - Low power",{wire_soundemitter_sound="wtiberium/gdi/Aeva_LowPower.wav"})
list.Set("WireSounds","Scrin - Tiberium exposure",{wire_soundemitter_sound="wtiberium/gdi/Aeva_TiberExposDet.wav"})
list.Set("WireSounds","Scrin - Tiberium weapon ready",{wire_soundemitter_sound="wtiberium/gdi/Aeva_TiberWeaReady.wav"})
list.Set("WireSounds","Scrin - TIberium field depleted",{wire_soundemitter_sound="wtiberium/gdi/Aeva_TibFieldDeple.wav"})

WTib_InfectedLifeForms = {}
WTib_MinGreenProductionRate = 30
WTib_MaxGreenProductionRate = 60
WTib_MinBlueProductionRate = 40
WTib_MaxBlueProductionRate = 80
WTib_MinRedProductionRate = 50
WTib_MaxRedProductionRate = 100
WTib_MaxFieldSize = 50
local TibFields = {}

if WDS and WDS.AddProtectionFunction then -- This is for my own damage system.
	WDS.AddProtectionFunction(function(ent)
		if ent.IsTiberium then
			return false
		end
	end)
end

/*
	***************************************************
	*                     WTiberium console commands                          *
	*                                                                                                  *
	***************************************************
*/

function WTib_MaxFieldSizeConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxFieldSize = tonumber(args[1])
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium field size changed to "..WTib_MaxFieldSize)
	end
end
concommand.Add("WTib_MaxFieldSize",WTib_MaxFieldSizeConsole)

function WTib_MaxGreenProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxGreenProductionRate = math.Clamp(tonumber(args[1]),tonumber(WTib_MinGreenProductionRate)+1,100000)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MaxGreenProductionRate)
	end
end
concommand.Add("WTib_MaxGreenProductionRate",WTib_MaxGreenProductionRateConsole)

function WTib_MinGreenProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MinGreenProductionRate = math.Clamp(tonumber(args[1]),1,tonumber(WTib_MaxGreenProductionRate)-1)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MinGreenProductionRate)
	end
end
concommand.Add("WTib_MinGreenProductionRate",WTib_MinGreenProductionRateConsole)

function WTib_MaxBlueProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxBlueProductionRate = math.Clamp(tonumber(args[1]),tonumber(WTib_MinBlueProductionRate)+1,100000)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum blue tiberium production rate changed to "..WTib_MaxBlueProductionRate)
	end
end
concommand.Add("WTib_MaxBlueProductionRate",WTib_MaxBlueProductionRateConsole)

function WTib_MinBlueProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MinBlueProductionRate = math.Clamp(tonumber(args[1]),1,tonumber(WTib_MaxBlueProductionRate)-1)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum blue tiberium production rate changed to "..WTib_MinBlueProductionRate)
	end
end
concommand.Add("WTib_MinBlueProductionRate",WTib_MinBlueProductionRateConsole)

function WTib_MaxRedProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxRedProductionRate = math.Clamp(tonumber(args[1]),tonumber(WTib_MinRedProductionRate)+1,100000)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum red tiberium production rate changed to "..WTib_MaxRedProductionRate)
	end
end
concommand.Add("WTib_MaxRedProductionRate",WTib_MaxRedProductionRateConsole)

function WTib_MinRedProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MinRedProductionRate = math.Clamp(tonumber(args[1]),1,tonumber(WTib_MaxRedProductionRate)-1)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum red tiberium production rate changed to "..WTib_MinRedProductionRate)
	end
end
concommand.Add("WTib_MinRedProductionRate",WTib_MinRedProductionRateConsole)

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
concommand.Add("WTib_ClearAllTiberium",WTib_ClearAllTiberiumConsole)

/*
	***************************************************
	*                               WTiberium Hooks                                     *
	*                                                                                                   *
	***************************************************
*/

function WTib_PlayerSpawn(ply)
	if WTib_IsInfected(ply) then
		WTib_CureInfection(ply)
	end
end
hook.Add("PlayerSpawn","WTib_PlayerSpawn",WTib_PlayerSpawn)

function WTib_WDeathTibDoll(ent,rag)
	if WTib_IsInfected(ent) then
		WTib_RagdollToTiberium(rag,function(rag)
			if rag and rag:IsValid() then
				WDeath_AddRagdollToList(rag)
			end
		end)
		return rag
	end
end
hook.Add("WDeath_DeathdollCreated","WTib_WDeathTibDoll",WTib_WDeathTibDoll)

function WTib_LOLRAOEP(ply,txt,team)
	return string.Replace(string.lower(txt),"god","alien")
end
hook.Add("PlayerSay","WTib_LOLRAOEP",WTib_LOLRAOEP)

timer.Create("WTib_Think",2,0,function()
	local e = WTib_GetAllTiberium()[1] or NULL
	for _,v in pairs(WTib_InfectedLifeForms) do
		if v and v:IsValid() and (v:IsPlayer() and v:Alive()) then
			v:TakeDamage(1,v.WTib_Infector or e,v.WTib_Infector or e)
		end
	end
end)

/*
	***************************************************
	*                       WTiberium field management                         *
	*                                                                                                   *
	***************************************************
*/

function WTib_CreateNewField(e)
	local num = (table.Count(TibFields) or 0)+1
	local a = {}
	a.Leader = e
	a.Ents = {}
	TibFields[num] = a
	return num
end

function WTib_AddToField(f,e)
	if !TibFields[f] then return WTib_CreateNewField(e) end
	WTib_CheckOnField(f)
	table.insert(TibFields[tonumber(f)].Ents,e)
	return f
end

function WTib_GetFieldEnts(f)
	if !TibFields[f] then return {} end
	return TibFields[f].Ents or {}
end

function WTib_GetFieldLeader(f)
	if !TibFields[f] then return end
	return TibFields[f].Leader
end

function WTib_CheckOnField(f)
	local tab = TibFields[f]
	if !TibFields[f] then return false end
	if !TibFields[f].Leader or !TibFields[f].Leader:IsValid() then
		for k,v in SortedPairs(TibFields[f].Ents) do
			if v and v:IsValid() then
				TibFields[f].Leader = v
				TibFields[f].Ents[k] = nil
				break
			end
		end
	end
	local a = {}
	for _,v in pairs(TibFields[f].Ents) do
		if v and v:IsValid() then
			table.insert(a,v)
		end
	end
	TibFields[f].Ents = a
	return true
end

/*
	***************************************************
	*                    WTiberium infection management                     *
	*                                                                                                   *
	***************************************************
*/

function WTib_InfectLiving(ply,e)
	if ply and ply:IsValid() and ((ply:IsPlayer() and ply:Alive()) or ply:IsNPC()) and !WTib_IsInfected(ply) then
		ply.WTib_Infector = e
		ply:SetColor(0,200,0,255)
		table.insert(WTib_InfectedLifeForms,ply)
	end
end

function WTib_CureInfection(ply)
	if ply and ply:IsValid() and (ply:IsPlayer() or ply:IsNPC()) then
		for k,v in pairs(WTib_InfectedLifeForms) do
			if v == ply then
				ply:SetColor(255,255,255,255)
				ply.WTib_LastTiberiumGasDamage = 0
				ply.WTib_InfectLevel = 0
				ply.WTib_Infector = nil
				WTib_InfectedLifeForms[k] = nil
				return true
			end
		end
		return false
	end
	return false
end

function WTib_IsInfected(ply)
	return table.HasValue(WTib_InfectedLifeForms,ply)
end

/*
	***************************************************
	*                       WTiberium Misc functions                             *
	*                                                                                                   *
	***************************************************
*/

function WTib_CreateTiberiumByTrace(t,ent,ply)
	if !t.Hit or (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then return end
	local e = ents.Create(ent or "wtib_tiberiumbase")
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	e.WDSO = ply
	e:Spawn()
	e:Activate()
	if t.Entity and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	if e.EmitGas then
		for i=1,3 do
			e:EmitGas()
		end
	end
	return e
end

function WTib_GetAllTiberium()
	local a = {}
	for _,v in pairs(ents.GetAll()) do
		if v.IsTiberium then
			table.insert(a,v)
		end
	end
	return a
end

function WTib_PropToTiberium(v)
	if v:GetClass() == "prop_ragdoll" then
		return WTib_RagdollToTiberium(v)
	end
	local e = ents.Create("wtib_tiberiumprop")
	e:SetPos(v:GetPos())
	e:SetModel(v:GetModel())
	e:SetMaterial(v:GetMaterial())
	e:SetAngles(v:GetAngles())
	e:SetColor(Color(0,200,20,230))
	e:SetSkin(v:GetSkin())
	e:SetCollisionGroup(v:GetCollisionGroup())
	e.Class = e:GetClass()
	if v.ZatMode == 1 then -- Zat compatability
		e.ZatMode = 2
		e.LastZat = v.LastZat or CurTime()
	end
	e:Spawn()
	e:Activate()
	v:Remove()
	return e
end

function WTib_RagdollToTiberium(rag)
	if !rag or !rag:GetClass() == "prop_ragdoll" then return false end
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
	rag.ReproductionRate			= 0
	rag.MinTiberiumGain				= 0
	rag.MaxTiberiumGain				= 0
	rag.ShouldReproduce				= false
	rag.NoPhysicsPickup				= true
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

function WTib_TiberiumRagdollToRagdoll(rag)
	if !rag or !rag:GetClass() == "prop_ragdoll" or !rag.IsTiberium then return false end
	rag:SetCollisionGroup(rag.WTib_OldCollisionGroup)
	rag.TiberiumDraimOnReproduction	= nil
	rag.MinReprodutionTibRequired	= nil
	rag.WTib_OldCollisionGroup		= nil
	rag.DrainTiberiumAmount			= nil
	rag.RemoveOnNoTiberium			= nil
	rag.SetTiberiumAmount			= nil
	rag.AddTiberiumAmount			= nil
	rag.GetTiberiumAmount			= nil
	rag.ReproductionRate			= nil
	rag.NoPhysicsPickup				= nil
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

function WTib_SupplyResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.SupplyResource(a,b,c)
		elseif WTib_IsRD2() then
			return RD_SupplyResource(a,b,c)
		end
	end
end

function WTib_ConsumeResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.ConsumeResource(a,b,c)
		elseif WTib_IsRD2() then
			return RD_ConsumeResource(a,b,c)
		end
	end
end

function WTib_AddResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.AddResource(a,b,c)
		elseif WTib_IsRD2() then
			return RD_AddResource(a,b,c)
		end
	end
end

function WTib_GetResourceAmount(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.GetResourceAmount(a,b,c)
		elseif WTib_IsRD2() then
			return RD_GetResourceAmount(a,b,c)
		end
		return 0
	end
	return 0
end

function WTib_RemoveRDEnt(a)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.RemoveRDEntity(a)
		elseif Dev_Unlink_All and a.resources2links then
			return Dev_Unlink_All(a)
		end
	end
end

function WTib_GetNetworkCapacity(a,b)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.GetNetworkCapacity(a,b)
		elseif WTib_IsRD2() then
			return RD_GetNetworkCapacity(a,b)
		end
		return 0
	end
	return 0
end

function WTib_BuildDupeInfo(a)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.BuildDupeInfo(a)
		elseif WTib_IsRD2() then
			return RD_BuildDupeInfo(a)
		end
	end
end

function WTib_ApplyDupeInfo(a,b)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD_3.ApplyDupeInfo(a,b)
		elseif WTib_IsRD2() then
			return RD_ApplyDupeInfo(a,b)
		end
	end
end

function WTib_RegisterEnt(a,b)
	if LS_RegisterEnt then
		return LS_RegisterEnt(a,b)
	end
end

/*
	***************************************************
	*         Wire shit down here, these are all placeholders          *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_CreateInputs(a,b,c)
	if WireAddon then
		return Wire_CreateInputs(a,b,c)
	end
end

function WTib_CreateOutputs(a,b)
	if WireAddon then
		return Wire_CreateOutputs(a,b)
	end
end

function WTib_TriggerOutput(a,b,c)
	if WireAddon then
		return Wire_TriggerOutput(a,b,math.Round(c))
	end
end

function WTib_Restored(a)
	return Wire_Restored(a)
end

function WTib_Remove(a)
	if WireAddon then
		return Wire_Remove(a)
	end
end
