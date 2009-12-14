AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	//self:SetModel("models/props_lab/blastdoor001c.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On"})
	self.Outputs = WTib_CreateOutputs(self,{"Online","Energy"})
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_sonicplating")
	e:SetModel("models/props_lab/blastdoor001c.mdl")
	e:SetPos(t.HitPos+t.HitNormal*25)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self.Out.Energy = WTib_GetResourceAmount(self,"energy")
	if self.In.On != 0 and self.Out.Energy > 1 then
		self.Out.Online = 1
		WTib_ConsumeResource(self,"energy",1)
	else
		self.Out.Online = 0
	end
	self:UpdateWire()
end

function ENT:TriggerInput(name,val)
	self.In[name] = tonumber(val)
end

WTib_ApplyFunctionsSV(ENT)
