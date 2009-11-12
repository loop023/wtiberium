AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

SWEP.MaxTib = 50
SWEP.MaxAmmo = 50
SWEP.LastShot = 0
SWEP.NextRegen = 0

function SWEP:Initialize()
	self:SetWeaponHoldType("physgun")
	self.Weapon:SetNWInt("Tiberium",0)
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	self:SetClip1(self:Clip1()-1)
	local dmg = 15
	local Tib = self.Weapon:GetNWInt("Tiberium")
	if Tib > 0 then
		self.Weapon:SetNWInt("Tiberium",Tib-1)
		dmg = math.random(15,40)
	end
	local tr = self.Owner:GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity:IsValid() then
		tr.Entity:TakeDamage(dmg,self.Owner,self)
	end
	local ed = EffectData()
	ed:SetEntity(self.Owner)
	ed:SetStart(self.Owner:GetShootPos())
	ed:SetOrigin(tr.HitPos)
	ed:SetMagnitude(dmg)
	util.Effect("wtib_tiberiumlaser",ed)
	self:SetNextPrimaryFire(CurTime()+0.1)
	self:SetNextSecondaryFire(CurTime()+0.3)
	self.NextRegen = CurTime()+1.5
	return true
end

function SWEP:SecondaryAttack()
	local tr = self.Owner:GetEyeTrace()
	local Tib = self.Weapon:GetNWInt("Tiberium")
	if !tr.Hit or !tr.Entity or !tr.Entity:IsValid() or tr.HitPos:Distance(self.Owner:GetShootPos()) > 70 or !tr.Entity.IsTiberium or Tib >= self.MaxTib then return end
	local Add = math.Clamp(tr.Entity:GetTiberiumAmount(),0,math.random(3,8))
	if Tib+Add > self.MaxTib then
		Add = Add-(Tib+(Add-self.MaxTib))
	end
	self.Weapon:SetNWInt("Tiberium",Tib+Add)
	tr.Entity:DrainTiberiumAmount(Add)
	self:SetNextSecondaryFire(CurTime()+0.1)
	self:SetNextPrimaryFire(CurTime()+0.3)
	return true
end

function SWEP:Think()
	if self:Clip1() < self.MaxAmmo and self.NextRegen <= CurTime() then
		self:SetClip1(self:Clip1()+1)
		self.NextRegen = CurTime()+0.12
	end
end
