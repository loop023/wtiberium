AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props/de_train/Barrel.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.MaxHealth = 500
	self.aHealth = self.MaxHealth
	self.Outputs = WTib_CreateOutputs(self,{"TiberiumChemicals","MaxTiberiumChemicals"})
	WTib_AddResource(self,"TiberiumChemicals",3300)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_smallchemtibstorage")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWInt("ChemTib",WTib_GetResourceAmount(self,"TiberiumChemicals"))
	WTib_TriggerOutput(self,"TiberiumChemicals",WTib_GetResourceAmount(self,"TiberiumChemicals"))
	WTib_TriggerOutput(self,"MaxTiberiumChemicals",WTib_GetNetworkCapacity(self,"TiberiumChemicals"))
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
