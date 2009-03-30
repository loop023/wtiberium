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
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.MaxTiberiumEntsPerRun = 5
	self.NextHarvest = 0
	self.DamageLeak = 0
	self.ForceLeak = 0
	self.MaxHealth = 500
	self.NextLeak = 0
	self.aHealth = self.MaxHealth
	self.Outputs = Wire_CreateOutputs(self,{"Online"})
	self.Inputs = Wire_CreateInputs(self,{"On"})
	self.Active = false
	WTib_AddResource(self,"Tiberium",0)
	WTib_AddResource(self,"energy",0)
	LS_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_harvester")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Harvest()
	local a = 0
	for _,v in pairs(ents.FindInSphere(self:GetPos(),200)) do
		if a >= self.MaxTiberiumEntsPerRun then return end
		if v.IsTiberium then
			local am = math.Clamp(v:GetTiberiumAmount(),0,math.random(v.MinTiberiumGain or 15,MaxTiberiumGain or 50))
			if WTib_GetResourceAmount(self,"energy") < am*1.5 then
				self:TurnOff()
				return
			end
			WTib_ConsumeResource(self,"energy",am*1.5)
			v:DrainTiberiumAmount(am)
			WTib_SupplyResource(self,"Tiberium",am)
		end
		a = a+1
	end
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
	self.Entity:StopSound("apc_engine_start")
	if self.Active then
		self.Entity:EmitSound("apc_engine_stop")
	end
	self.Active = false
end

function ENT:TurnOn()
	self.Entity:EmitSound("apc_engine_start")
	self.Active = true
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
