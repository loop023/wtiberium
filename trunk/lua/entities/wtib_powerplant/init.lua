AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextPower = 0

function ENT:Initialize()
	self:SetModel("models/props_wasteland/laundry_washer003.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On"})
	self.Outputs = WTib_CreateOutputs(self,{"Online"})
	WTib_AddResource(self,"RefinedTiberium",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_powerplant")
	e:SetPos(t.HitPos+t.HitNormal*30)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local a = 0
	local rand = math.Rand(50,200)
	local RTib = WTib_GetResourceAmount(self,"RefinedTiberium")
	if self.Active and RTib >= rand and self.NextPower <= CurTime() then
		WTib_ConsumeResource(self,"RefinedTiberium",rand)
		WTib_SupplyResource(self,"energy",rand*1.5)
		a = 1
	else
		self:TurnOff()
	end
	local o = false
	if a == 1 then
		o = true
	end
	local En = WTib_GetResourceAmount(self,"energy")
	local RT = WTib_GetResourceAmount(self,"RefinedTiberium")
	self:SetNWBool("Online",o)
	self:SetNWInt("energy",En)
	self:SetNWInt("RefTib",RT)
	WTib_TriggerOutput(self,"Online",a)
	WTib_TriggerOutput(self,"Energy",En)
	WTib_TriggerOutput(self,"Refined Tiberium",TC)
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
	self:EmitSound("apc_engine_start")
	self.Active = true
end

function ENT:OnRemove()
	if WTib_IsRD3() then
		RD.RemoveRDEntity(self)
	elseif Dev_Unlink_All and self.resources2links then
		Dev_Unlink_All(self)
	end
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
