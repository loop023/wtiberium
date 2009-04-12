AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

function ENT:Initialize()
	self:SetModel("models/props_industrial/oil_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.NextHarvest = 0
	self.Outputs = Wire_CreateOutputs(self,{"Online"})
	self.Inputs = Wire_CreateInputs(self,{"On"})
	self.Active = false
	WTib_AddResource(self,"Tiberium",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_mediumharvester")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Harvest()
	local a = 0
	for _,v in pairs(ents.FindInSphere(self:GetPos(),300)) do
		if a >= 5 then return end
		if v.IsTiberium then
			local am = math.Clamp(v:GetTiberiumAmount(),0,math.Rand(v.MinTiberiumGain or 50,MaxTiberiumGain or 150))
			if WTib_GetResourceAmount(self,"energy") < am*2 then
				self:TurnOff()
				return
			end
			WTib_ConsumeResource(self,"energy",am*2)
			v:DrainTiberiumAmount(am)
			WTib_SupplyResource(self,"Tiberium",am)
			self:DoSparkEffect(v,math.Clamp((am/10)-35,5,15))
			a = a+1
		end
	end
end

function ENT:DoSparkEffect(te,size)
	local e = ents.Create("point_tesla")
	e:SetKeyValue("targetname","teslab")
	e:SetKeyValue("m_SoundName","DoSpark")
	e:SetKeyValue("texture","sprites/physbeam.spr")
	e:SetKeyValue("m_Color","200 200 255")
	e:SetKeyValue("m_flRadius",tostring(size*80))
	e:SetKeyValue("beamcount_min",tostring(math.ceil(size+4)))
	e:SetKeyValue("beamcount_max",tostring(math.ceil(size+12)))
	e:SetKeyValue("thick_min",tostring(size))
	e:SetKeyValue("thick_max",tostring(size*8))
	e:SetKeyValue("lifetime_min","0.1")
	e:SetKeyValue("lifetime_max","0.2")
	e:SetKeyValue("interval_min","0.05")
	e:SetKeyValue("interval_max","0.08")
	e:SetPos(te:GetPos()+Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(0,20)))
	e:Spawn()
	e:Fire("DoSpark","",0)
	e:Fire("kill","",1)
end

function ENT:Think()
	if self.NextHarvest <= CurTime() and self.Active then
		self:Harvest()
		self.NextHarvest = CurTime()+1
	end
	local a = 0
	if self.Active then
		a = 1
	end
	Wire_TriggerOutput(self,"Online",a)
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	if self.Active then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		if val == 0 then
			self:TurnOff()
		else
			self:TurnOn()
		end
	end
end

function ENT:TurnOff()
	self:StopSound("apc_engine_start")
	if self.Active then
		self:EmitSound("apc_engine_stop")
	end
	self.Active = false
end

function ENT:TurnOn()
	if !self.Active then
		self:EmitSound("apc_engine_start")
	end
	self.Active = true
end

function ENT:OnRemove()
	WTib_RemoveRDEnt(self)
	if WireAddon and (self.Outputs or self.Inputs) then
		Wire_Remove(self)
	end
end

function ENT:OnRestore()
	if WireAddon then
		Wire_Restored(self)
	end
end

function ENT:PreEntityCopy()
	WTib_BuildDupeInfo(self)
	if WireAddon != nil then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
	WTib_ApplyDupeInfo(Ent,CreatedEntities)
	if WireAddon != nil and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
	end
end
