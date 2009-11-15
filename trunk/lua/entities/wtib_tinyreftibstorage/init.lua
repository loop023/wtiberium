AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--ENT.MaxHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you
--ENT.aHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiny_tiberium_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib_CreateOutputs(self,{"RefinedTiberium","MaxRefinedTiberium"})
	WTib_AddResource(self,"RefinedTiberium",750)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_tinyreftibstorage")
	e:SetPos(t.HitPos+t.HitNormal*14)
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

WTib_ApplyFunctionsSV(ENT)
