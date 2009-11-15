AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--ENT.MaxHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you
--ENT.aHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you

function ENT:Initialize()
	self:SetModel("models/Tiberium/large_tiberium_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib_CreateOutputs(self,{"Tiberium","MaxTiberium"})
	WTib_AddResource(self,"Tiberium",6000)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_largetibstorage")
	e:SetPos(t.HitPos+t.HitNormal*45)
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

WTib_ApplyFunctionsSV(ENT)
