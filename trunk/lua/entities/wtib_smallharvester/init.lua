AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.NextHarvest = 0
ENT.Active = false

function ENT:Initialize()
	self:SetModel("models/Tiberium/small_harvester.mdl")
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
	local e = ents.Create("wtib_smallharvester")
	e:SetPos(t.HitPos+t.HitNormal*12)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Harvest()
	local a = 0
	local En = WTib_GetResourceAmount(self,"energy")
	local Multipl = 1.5
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetUp(),100,10)) do
		if a >= 3 then break end
		if v.IsTiberium and v.CanBeHarvested then
			local am = math.Clamp(v:GetTiberiumAmount(),0,math.Rand(15,50))
			if En < am*Multipl then
				self:TurnOff()
				return
			end
			WTib_ConsumeResource(self,"energy",am*Multipl)
			v:DrainTiberiumAmount(am)
			WTib_SupplyResource(self,"Tiberium",am)
			self:DoSparkEffect(v,math.Clamp((am/10)-35,1,10))
			a = a+1
		end
	end
	En = WTib_GetResourceAmount(self,"energy")
	WTib_TriggerOutput(self,"Online",a)
	WTib_TriggerOutput(self,"Energy",En)
	WTib_TriggerOutput(self,"Tiberium",WTib_GetResourceAmount(self,"Tiberium"))
end

function ENT:DoSparkEffect(te,size)
	local e = ents.Create("point_tesla")
	e:SetKeyValue("targetname","teslab")
	e:SetKeyValue("m_SoundName","DoSpark")
	e:SetKeyValue("texture","sprites/physbeam.spr")
	e:SetKeyValue("m_Color","200 200 255")
	e:SetKeyValue("m_flRadius",tostring(size*80))
	e:SetKeyValue("beamcount_min",tostring(math.ceil(size+4)))
	e:SetKeyValue("beamcount_max",tostring(math.ceil(size+12)))
	e:SetKeyValue("thick_min",tostring(size))
	e:SetKeyValue("thick_max",tostring(size*8))
	e:SetKeyValue("lifetime_min","0.1")
	e:SetKeyValue("lifetime_max","0.2")
	e:SetKeyValue("interval_min","0.05")
	e:SetKeyValue("interval_max","0.08")
	e:SetPos(te:GetPos()+Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(0,20)))
	e:Spawn()
	e:Fire("DoSpark","",0)
	e:Fire("kill","",1)
end

function ENT:Think()
	local En = WTib_GetResourceAmount(self,"energy")
	if self.Active then
		if En < 50 then
			self:TurnOff()
		elseif self.NextHarvest <= CurTime() then
			self:Harvest()
			self.NextHarvest = CurTime()+1
		end
	end
	self:SetNWInt("energy",En)
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	if self.Active then
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
	if self.Active then
		self:EmitSound("apc_engine_stop")
	end
	self:SetNWBool("Online",false)
	self.Active = false
end

function ENT:TurnOn()
	if !self.Active then
		self:EmitSound("apc_engine_start")
	end
	if WTib_GetResourceAmount(self,"energy") < 50 then self:TurnOff() return end
	self:SetNWBool("Online",true)
	self.Active = true
	local ed = EffectData()
		ed:SetEntity(self)
		ed:SetMagnitude(100)
	util.Effect("WTib_HarvesterBeam",ed)
end

WTib_ApplyFunctionsSV(ENT)
