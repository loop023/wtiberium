AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/HealthKit.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = Wire_CreateInputs(self,{"On","Radius"})
	self.Outputs = Wire_CreateOutputs(self,{"Online","Radius"})
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
	self.ShouldBeActive = false
	self:SetNWBool("Online",false)
	Wire_TriggerOutput(self,"Online",0)
	self:SetNWInt("Radius",512)
	Wire_TriggerOutput(self,"Radius",512)
	self.NextEnergyDrain = 0
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_sonicfieldemitter")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local am = (self:GetNWInt("Radius") or 512)/math.Rand(1.5,2.5)
	if self.ShouldBeActive and WTib_GetResourceAmount(self,"energy") > am then
		if self.NextEnergyDrain <= CurTime() then
			WTib_ConsumeResource(self,"energy",am)
		end
		self.NextEnergyDrain = CurTime()+1
		self:SetNWBool("Online",true)
		Wire_TriggerOutput(self,"Online",1)
	else
		self:SetNWBool("Online",false)
		Wire_TriggerOutput(self,"Online",0)
	end
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		local a = true
		if val == 0 then
			a = false
		end
		self.ShouldBeActive = a
	elseif name == "Radius" then
		local a = math.Clamp(val or 512,10,1024)
		self:SetNWInt("Radius",a)
		Wire_TriggerOutput(self,"Radius",a)
	end
end
