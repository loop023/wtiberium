AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.Accelerators = {}

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_growth_accelerator.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On"})
	self.Outputs = WTib_CreateOutputs(self,{"Online","Energy","Tiberium"})
	WTib_AddResource(self,"Tiberium",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_mediumgrowthaccelerator")
	e:SetPos(t.HitPos+t.HitNormal*44)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local Energy = WTib_GetResourceAmount(self,"energy")
	self:SetNWInt("energy",Energy)
	WTib_TriggerOutput(self,"Energy",Energy)
	if self:GetNWBool("Online") then
		WTib_TriggerOutput(self,"Online",1)
		for _,v in pairs(ents.FindInSphere(self:GetPos(),512)) do
			if v.IsTiberium and v.CanBeHarvested and Energy >= 50 then
				v:Accelerate(CurTime()+1)
			end
		end
	else
		WTib_TriggerOutput(self,"Online",0)
	end
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	if self:GetNWBool("Online",false) then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		if val == 0 then
			self:TurnOff()
		else
			self:TurnOn()
		end
	end
end

function ENT:TurnOff()
	self:StopSound("apc_engine_start")
	if self:GetNWBool("Online",false) then
		self:EmitSound("apc_engine_stop")
	end
	self:SetNWBool("Online",false)
	WTib_TriggerOutput(self,"Online",0)
	for _,v in pairs(self.Accelerators) do
		v:SetGrowthAccelerate(false)
	end
end

function ENT:TurnOn()
	if !self:GetNWBool("Online",false) then
		self:EmitSound("apc_engine_start")
	end
	self:SetNWBool("Online",true)
	WTib_TriggerOutput(self,"Online",1)
end

WTib_ApplyFunctionsSV(ENT)
