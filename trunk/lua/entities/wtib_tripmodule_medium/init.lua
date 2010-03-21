AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_trip.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy"})
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_tripmodule_medium")
	e:SetPos(t.HitPos+t.HitNormal*16)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local Count = 0
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetForward(),625,25)) do
		if v.IsTiberium then
			Count = Count+1
		end
	end
	self.dt.Online = Count >= 1
	self.dt.Energy = WTib.GetResourceAmount(self,"energy")
	WTib.TriggerOutput(self,"Online",tonumber(self.dt.Online))
	WTib.TriggerOutput(self,"Energy",self.dt.Energy)
	WTib.SupplyResource(self,"energy",Count*math.Rand(5,10))
	self:NextThink(CurTime()+1)
	return true
end

function ENT:OnRestore()
	WTib.Restored(self)
end
