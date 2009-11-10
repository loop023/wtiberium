AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Tiberium/large_trip.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib_CreateOutputs(self,{"Online"})
	WTib_AddResource(self,"energy",0)
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_largetrip")
	e:SetPos(t.HitPos+t.HitNormal*10)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local Count = 0
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetForward(),750,30)) do
		if v.IsTiberium then
			Count = Count+1
		end
	end
	WTib_SupplyResource(self,"energy",Count*math.Rand(10,60))
	self:SetNWBool("Online",Count >= 1)
	WTib_TriggerOutput(self,"Online",tonumber(Count >= 1))
end

function ENT:OnRemove()
	WTib_RemoveRDEnt(self)
	if self.Outputs or self.Inputs then
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
