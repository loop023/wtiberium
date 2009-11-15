AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiny_trip.mdl")
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
	local e = ents.Create("wtib_tinytrip")
	e:SetPos(t.HitPos+t.HitNormal*12)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local Count = 0
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetForward(),375,15)) do
		if v.IsTiberium then
			Count = Count+1
		end
	end
	WTib_SupplyResource(self,"energy",Count*math.Rand(2.5,7.5))
	self:SetNWBool("Online",Count >= 1)
	WTib_TriggerOutput(self,"Online",tonumber(Count >= 1))
end

WTib_ApplyFunctionsSV(ENT)
