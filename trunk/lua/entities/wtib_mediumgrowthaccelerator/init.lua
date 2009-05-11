AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.Active = false

function ENT:Initialize()
	self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On"})
	self.Outputs = WTib_CreateOutputs(self,{"Online","Energy","Tiberium"})
	WTib_AddResource(self,"Tiberium",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_mediumgrowthaccelerator")
	e:SetPos(t.HitPos+t.HitNormal*20)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
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
	WTib_TriggerOutput(self,"Online",0)
end

function ENT:TurnOn()
	if !self.Active then
		self:EmitSound("apc_engine_start")
	end
	self.Active = true
	WTib_TriggerOutput(self,"Online",1)
	for _,v in pairs(ents.FindInSphere(self:GetPos(),512)) do
		if v.IsTiberium and v.CanBeHarvested then
			--v:SetGrowthAccelerate(true)
		end
	end
end

function ENT:OnRemove()
	WTib_RemoveRDEnt(self)
	if (self.Outputs or self.Inputs) then
		WTib_Remove(self)
	end
end

function ENT:OnRestore()
	WTib_Restored(self)
end

function ENT:PreEntityCopy()
	WTib_BuildDupeInfo(self)
	if WireAddon then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
	WTib_ApplyDupeInfo(Ent,CreatedEntities)
	if WireAddon and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
	end
end
