AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_tiberium_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"RawTiberium","MaxRawTiberium"})
	WTib.AddResource(self,"RawTiberium",3000)
	WTib.RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_rawtibstorage_medium")
	e:SetPos(t.HitPos+t.HitNormal*30)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local RawTib = WTib.GetResourceAmount(self,"RawTiberium")
	self.dt.RawTiberium = RawTib
	WTib.TriggerOutput(self,"RawTiberium",RawTib)
	WTib.TriggerOutput(self,"MaxRawTiberium",WTib.GetNetworkCapacity(self,"RawTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end
