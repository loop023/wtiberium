AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--ENT.MaxHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you
--ENT.aHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you

function ENT:Initialize()
	self:SetModel("models/props_rooftop/SatelliteDish02.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On","Range","NoGreen","NoBlue","NoRed","Type"})
	self.Outputs = WTib_CreateOutputs(self,{"Online","Energy","Found","WorldX","WorldY","WorldZ","LocalX","LocalY","LocalZ"})
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
	self.In_On = 0
	self.In_Range = 0
	self.In_NoGreen = 0
	self.In_NoBlue = 0
	self.In_NoRed = 0
	self.In_Type = 0
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_radar")
	e:SetPos(t.HitPos+t.HitNormal*102)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:IsValidTarget(e)
	WTib_Print("Checking valid for entity "..tostring(e))
	if !e.IsTiberium then return false end // If it is no tiberium it is not a valid target.
	WTib_Print("\tIt is tiberium")
	if e.IsTiberiumParent then // If it is a parent crystal
		WTib_Print("\t\tParent crystal")
		if self.In_Type == 1 then // If we are only targetting normal crystals return false
			WTib_Print("\t\t\tOnly normal, invalid target.")
			return false
		end
	else
		WTib_Print("\t\tNo parent crystal")
		if self.In_Type == 2 then // If it is no parent crystal return false if the type is parent cystals.
			WTib_Print("\t\t\tOnly parent crystals, invalid target.")
			return false
		end
	end
	local Class = e:GetClass()
	if Class == "wtib_greentiberium" then // If it is green tiberium
		WTib_Print("\t\tGreen crystal")
		if self.In_NoGreen != 0 then // If we have green disabled return false
			WTib_Print("\t\t\tGreen is disabled crystal, invalid target.")
			return false
		end
	elseif Class == "wtib_bluetiberium" then
		WTib_Print("\t\tBlue crystal")
		if self.In_NoBlue != 0 then // If we have blue disabled return false
			WTib_Print("\t\t\tBlue is disabled crystal, invalid target.")
			return false
		end
	elseif Class == "wtib_tiberiumbase" then
		WTib_Print("\t\tRed crystal")
		if self.In_NoRed != 0 then // If we have red disabled return false
			WTib_Print("\t\t\tRed is disabled crystal, invalid target.")
			return false
		end
	end
	return true
end

function ENT:CheckOutputs()
	local En = WTib_GetResourceAmount(self,"energy")
	WTib_TriggerOutput(self,"Energy",En)
	self:SetNWInt("energy",En)
	if self.Target and self.Target:IsValid() then
		self:SetNWBool("HasTarget",true)
		WTib_TriggerOutput(self,"Found",1)
		local Pos = self.Target:GetPos()
		WTib_TriggerOutput(self,"WorldX",Pos.x)
		WTib_TriggerOutput(self,"WorldY",Pos.y)
		WTib_TriggerOutput(self,"WorldZ",Pos.z)
		local Pos = self:WorldToLocal(Pos)
		WTib_TriggerOutput(self,"LocalX",Pos.x)
		WTib_TriggerOutput(self,"LocalY",Pos.y)
		WTib_TriggerOutput(self,"LocalZ",Pos.z)
	else
		self:SetNWBool("HasTarget",false)
		WTib_TriggerOutput(self,"Found",0)
		WTib_TriggerOutput(self,"WorldX",0)
		WTib_TriggerOutput(self,"WorldY",0)
		WTib_TriggerOutput(self,"WorldZ",0)
		WTib_TriggerOutput(self,"LocalX",0)
		WTib_TriggerOutput(self,"LocalY",0)
		WTib_TriggerOutput(self,"LocalZ",0)
	end
end

function ENT:Think()
	local Drain = math.random(10,20)
	if WTib_GetResourceAmount(self,"energy") > Drain and self.In_On != 0 then
		self:SetNWBool("Online",true)
		if !self.Target or !self.Target:IsValid() then
			local Tab = ents.GetAll()
			if self.In_Range > 0 then
				Tab = ents.FindInSphere(self:GetPos(),self.In_Range)
			end
			local Dist = math.huge
			for _,v in pairs(Tab) do
				if self:GetPos():Distance(v:GetPos()) < Dist and self:IsValidTarget(v) then
					self.Target = v
				end
			end
		end
	else
		self:SetNWBool("Online",false)
		self.Target = nil
	end
	self:CheckOutputs()
end

function ENT:TriggerInput(name,val)
	self["In_"..name] = val
end

WTib_ApplyFunctionsSV(ENT)
