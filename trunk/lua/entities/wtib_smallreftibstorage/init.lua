AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.MaxHealth = 500
ENT.aHealth = 500

function ENT:Initialize()
	self:SetModel("models/props_c17/oildrum001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib_CreateOutputs(self,{"RefinedTiberium","MaxRefinedTiberium"})
	WTib_AddResource(self,"RefinedTiberium",3300)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_smallreftibstorage")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWInt("RefTib",WTib_GetResourceAmount(self,"RefinedTiberium"))
	WTib_TriggerOutput(self,"RefinedTiberium",WTib_GetResourceAmount(self,"RefinedTiberium"))
	WTib_TriggerOutput(self,"MaxRefinedTiberium",WTib_GetNetworkCapacity(self,"RefinedTiberium"))
end

function ENT:OnTakeDamage(di)
	self.aHealth = self.aHealth-di:GetDamage()
	if self.aHealth <= 0 then
		self:Die()
	end
end

function ENT:Die()
	self:Remove()
end

function ENT:Repair(am)
	if am <= 0 then return end
	self.aHealth = math.Clamp(self.aHealth+am,0,self.MaxHealth)
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
