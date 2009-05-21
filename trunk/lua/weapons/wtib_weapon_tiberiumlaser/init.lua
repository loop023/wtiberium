AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

SWEP.MaxTib = 200
SWEP.Tiberium = SWEP.MaxTib
SWEP.NextFire = 0
SWEP.NextCharge = 0

function SWEP:Initialize()
	self:SetWeaponHoldType("physgun")
end

function SWEP:PrimaryAttack()
	if self.NextFire > CurTime() then return false end
	local dmg = 20
	if self.Tiberium >= 1 then
		dmg = math.Clamp((dmg*self.Tiberium)/100,20,40)
		self.Tiberium = math.Clamp(self.Tiberium-math.Clamp((dmg/2),5,20),0,self.MaxTib)
	end
	local tr = self.Owner:GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity:IsValid() then
		tr.Entity:TakeDamage(dmg,self.Owner,self)
	end
	local ed = EffectData()
	ed:SetEntity(self.Owner)
	ed:SetOrigin(tr.HitPos)
	ed:SetMagnitude(dmg)
	util.Effect("wtib_tiberiumlaser",ed)
	self.NextFire = CurTime()+0.1
	self.NextCharge = CurTime()+0.3
	self.Weapon:SetNWInt("Tiberium",self.Tiberium)
	return true
end

function SWEP:SecondaryAttack()
	if self.NextCharge > CurTime() then return end
	local tr = self.Owner:GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity:IsValid() and tr.Entity.IsTiberium and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 70 and self.Tiberium < self.MaxTib then
		self.Tiberium = math.Clamp(self.Tiberium+math.Clamp(tr.Entity:GetTiberiumAmount(),0,10),0,self.MaxTib)
	end
	self.NextCharge = CurTime()+0.1
	self.NextFire = CurTime()+0.3
	self.Weapon:SetNWInt("Tiberium",self.Tiberium)
	return true
end
