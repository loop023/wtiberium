AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_wasteland/laundry_washer001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.MaxHealth = 500
	self.aHealth = self.MaxHealth
	self.Outputs = WTib_CreateOutputs(self,{"Tiberium","MaxTiberium"})
	WTib_AddResource(self,"Tiberium",3300)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_mediumtibstorage")
	e:SetPos(t.HitPos+t.HitNormal*40)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWInt("Tib",WTib_GetResourceAmount(self,"Tiberium"))
	WTib_TriggerOutput(self,"Tiberium",WTib_GetResourceAmount(self,"Tiberium"))
	WTib_TriggerOutput(self,"MaxTiberium",WTib_GetNetworkCapacity(self,"Tiberium"))
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
