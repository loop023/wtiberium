AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Armed = false

function ENT:Initialize()
	self:SetModel("models/props_phx/amraam.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_missile")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:PhysicsCollide(data,phys)
	local ent = data.HitEntity
	if ent then
		if !self.Armed and ent:IsValid() and ent.IsWarhead and ent.Explode != self.Explode then
			local a = ent:OnWarheadConnect(self)
			if a == true or a == nil then
				self.Explode = ent.Explode or self.Explode
				self:SetNWString("Warhead",ent.PrintName or ent:GetClass())
				ent:Remove()
			end
		elseif self.Armed and ent != self.MissileL then
			self:Explode(self,data)
		end
	end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if phys:IsValid() and self.Armed then
		phys:AddVelocity(self:GetForward()*10000)
	end
end

function ENT:Shoot()
	self.NoPhysicsPickup = true
	constraint.RemoveAll(self)
	self:SetParent(nil)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableDrag(false) 
		phys:SetMass(30)
        phys:Wake()
	end
	local e = ents.Create("env_fire_trail")
	e:SetAngles(self:GetAngles())
	e:SetPos(self:LocalToWorld(Vector(-70,0,7)))
	e:SetParent(self)
	e:Spawn()
	e:Activate()
	self.FTrail = e
	self.Armed = true
end

function ENT:PhysicsUpdate(phys)
	if !self.Armed then return end
	phys:ApplyForceCenter(self:GetForward()*20000)
	if self.Target and self.Target != Vector(0,0,0) and (self.LockDelay or 0) <= CurTime() then
		local Dist = math.min((self.Target - self:GetPos()):Length(), 5000)
		local Mod = math.Clamp(math.abs(Dist-5000)/3000,0.5,70)
		local TAng = (self.Target-self:GetPos()):Angle()
		local ang = self:GetAngles()
		ang.p = math.ApproachAngle(ang.p,TAng.p,Mod)
		ang.r = math.ApproachAngle(ang.r,TAng.r,Mod)
		ang.y = math.ApproachAngle(ang.y,TAng.y,Mod)
		if self:GetAngles() != ang then
			self:SetAngles(ang)
		end
		if Dist < 5 then
			self:Explode(self)
		end
	end
end

function ENT:Explode(missile,data)
	util.BlastDamage(missile,missile.WDSO,missile:GetPos(),math.Rand(200,300),math.Rand(300,400))
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	ed:SetScale(3)
	util.Effect("Explosion",ed)
	missile:Remove()
end
