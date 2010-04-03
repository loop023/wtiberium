AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_chemical_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"ChemicalTiberium","MaxChemicalTiberium"})
	WTib.AddResource(self,"ChemicalTiberium",3000)
	WTib.RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,30,self)
end

function ENT:Think()
	local RefTib = WTib.GetResourceAmount(self,"ChemicalTiberium")
	self.dt.ChemicalTiberium = RefTib
	WTib.TriggerOutput(self,"ChemicalTiberium",RefTib)
	WTib.TriggerOutput(self,"MaxChemicalTiberium",WTib.GetNetworkCapacity(self,"ChemicalTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end
