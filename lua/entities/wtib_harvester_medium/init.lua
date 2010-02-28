AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.NextHarvest = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_harvester.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy","RawTiberium"})
	WTib.AddResource(self,"RawTiberium",0)
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_harvester_medium")
	e:SetPos(t.HitPos+t.HitNormal*23)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Harvest()
	local Energy = WTib.GetResourceAmount(self,"energy")
	local SPos = self:GetPos()
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetUp(),250,10)) do
		if v.IsTiberium then
			local Drain = math.Clamp(v:GetTiberiumAmount(),math.Clamp(v:GetTiberiumAmount(),1,20),math.Clamp(SPos:Distance(v:GetPos())/2,40,200))
			if Energy > Drain then
				WTib.ConsumeResource(self,"energy",Drain)
				WTib.SupplyResource(self,"RawTiberium",Drain)
				Energy = WTib.GetResourceAmount(self,"energy")
				v:SetTiberiumAmount(v:GetTiberiumAmount()-Drain)
			else
				self:TurnOff()
				break
			end
		end
	end
end

function ENT:Think()
	if self.NextHarvest <= CurTime() then
		if WTib.GetResourceAmount(self,"energy") < 10 then
			self:TurnOff()
		end
		if self.dt.Online then
			WTib.ConsumeResource(self,"energy",10)
			self:Harvest()
			self.NextHarvest = CurTime()+1
		end
	end
	local Energy = WTib.GetResourceAmount(self,"energy")
	WTib.TriggerOutput(self,"Energy",Energy)
	WTib.TriggerOutput(self,"RawTiberium",WTib.GetResourceAmount(self,"RawTiberium"))
	self.dt.Energy = Energy
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
	if WTib.GetResourceAmount(self,"energy") <= 10 then return end
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
	end
end
