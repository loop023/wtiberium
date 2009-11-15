AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--ENT.MaxHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you
--ENT.aHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_energy_cell.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib_CreateOutputs(self,{"Energy","MaxEnergy"})
	WTib_AddResource(self,"energy",3000)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_mediumenergystorage")
	e:SetPos(t.HitPos+t.HitNormal*18)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWInt("energy",WTib_GetResourceAmount(self,"energy"))
	WTib_TriggerOutput(self,"Energy",WTib_GetResourceAmount(self,"energy"))
	WTib_TriggerOutput(self,"MaxEnergy",WTib_GetNetworkCapacity(self,"energy"))
end

WTib_ApplyFunctionsSV(ENT)
