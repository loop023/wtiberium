AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local OffsetVector = Vector(5,0,0)

ENT.Locked = false

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiberium_missile_launcher.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"Fire","Lock","LockDelay","X","Y","Z"})
	self.Outputs = WTib_CreateOutputs(self,{"Can Fire"})
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_missilelauncher")
	e:SetPos(t.HitPos+t.HitNormal*13)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	if self.Missile and self.Missile:IsValid() then
		self:SetNWBool("Loaded",true)
	else
		self:SetNWBool("Loaded",false)
	end
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	self:Shoot()
end

function ENT:TriggerInput(name,val)
	if name == "Fire" then
		if val != 0 then
			self:Shoot()
		end
	elseif name == "Lock" then
		if val == 1 then
			self.Locked = true
		else
			self.Locked = false
		end
	elseif name == "LockDelay" then
		self.LockDelay = val
	elseif name == "X" then
		self.CoX = val
	elseif name == "Y" then
		self.CoY = val
	elseif name == "Z" then
		self.CoZ = val
	end
end

function ENT:Shoot()
	if self.Missile and self.Missile:IsValid() then
		self.Missile:Shoot()
		self.Missile.LockDelay = CurTime()+(self.LockDelay or 0.5)
		if self.Locked then
			self.Missile.Target = Vector(self.CoX or 0,self.CoY or 0,self.CoZ or 0)
		end
		self.Missile.NoLauncher = true
		self.Missile = nil
		WTib_TriggerOutput(self,"Can Fire",0)
	end
end

function ENT:Touch(ent)
	if ent:GetClass() == "wtib_missile" and !ValidEntity(self.Missile) and !ent.NoLauncher then
		ent:SetAngles(self:GetAngles())
		ent:SetPos(self:LocalToWorld(OffsetVector))
		ent:SetParent(self)
		constraint.Weld(self,ent,0,0,0,false)
		constraint.NoCollide(self,ent,0,0)
		ent.MissileL = self
		self.Missile = ent
		WTib_TriggerOutput(self,"Can Fire",1)
	end
end

function ENT:OnRestore(self)
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
