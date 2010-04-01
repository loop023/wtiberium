AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.NextSupply = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/large_tiberium_reactor.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On","Type"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Type","Resource"})
	for _,v in pairs(self.Resources) do
		WTib.AddResource(self,v.Resource,0)
	end
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_powergen_medium")
	e:SetPos(t.HitPos+t.HitNormal*143)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self.dt.Resource = WTib.GetResourceAmount(self,self:GetTypeString())
	if self.dt.Online and self.NextSupply <= CurTime() then
		if self.dt.Resource >= self:GetTypeTable().Drain then
			WTib.ConsumeResource(self,self:GetTypeString(),self:GetTypeTable().Drain)
			WTib.SupplyResource(self,"energy",self:GetTypeTable().Supply)
		else
			self:TurnOff()
		end
		self.NextSupply = CurTime()+1
	end
	self.dt.Resource = WTib.GetResourceAmount(self,self:GetTypeString())
	WTib.TriggerOutput(self,"Resource",self.dt.Resource)
	WTib.TriggerOutput(self,"Type",self:GetType())
	self.dt.Type = self:GetType()
end

function ENT:SetType(int)
	self.dt.Type = int
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:Use(ply)
	if self.dt.Online then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:TurnOn()
	if WTib.GetResourceAmount(self,self:GetTypeString()) <= 1 then return end
	if !self.dt.Online then
		self:EmitSound("apc_engine_start")
	end
	self.dt.Online = true
	WTib.TriggerOutput(self,"Online",1)
end

function ENT:OnRemove()
	self:TurnOff()
end

function ENT:TurnOff()
	self:StopSound("apc_engine_start")
	if self.dt.Online then
		self:EmitSound("apc_engine_stop")
	end
	self.dt.Online = false
	WTib.TriggerOutput(self,"Online",0)
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		if val == 0 then
			self:TurnOff()
		else
			self:TurnOn()
		end
	elseif name == "Type" then
		self.dt.Type = math.Clamp(val,0,table.Count(self.Resources))
	end
end
