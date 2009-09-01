AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextSonicEmit = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/sonic_field_emitter.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On","SetRadius"})
	self.Outputs = WTib_CreateOutputs(self,{"Online","Radius"})
	WTib_TriggerOutput(self,"Online",0)
	self:SetNWInt("Radius",512)
	WTib_TriggerOutput(self,"Radius",512)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_sonicfieldemitter")
	e:SetPos(t.HitPos+t.HitNormal*15)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local am = (self:GetNWInt("Radius") or 512)/math.Rand(1.5,2.5)
	local a = 0
	if self:GetNWBool("Online",false) and WTib_GetResourceAmount(self,"energy") > am then
		if self.NextSonicEmit <= CurTime() then
			WTib_ConsumeResource(self,"energy",am)
			for _,v in pairs(ents.FindInSphere(self:GetPos(),self:GetNWInt("Radius") or 512)) do
				if v.IsTiberium then
					v:DrainTiberiumAmount(math.Rand(170,300))
				end
			end
			self.NextSonicEmit = CurTime()+1
		end
		self:TurnOn()
		a = 1
	else
		self:TurnOff()
		a = 0
	end
	WTib_TriggerOutput(self,"Online",a)
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
	elseif name == "SetRadius" then
		local a = math.Clamp(val or 512,10,1024)
		self:SetNWInt("Radius",a)
		WTib_TriggerOutput(self,"Radius",a)
	end
end

function ENT:TurnOn()
	self:SetNWBool("Online",true)
end

function ENT:TurnOff()
	self:SetNWBool("Online",false)
end

function ENT:OnRestore()
	WTib_Restored(self)
end

function ENT:PreEntityCopy()
	WTib_BuildDupeInfo(self)
	if WireAddon then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
	WTib_ApplyDupeInfo(Ent,CreatedEntities)
	if WireAddon and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
	end
end
