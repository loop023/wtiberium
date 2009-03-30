AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function SWEP:PrimaryAttack()
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	self:TakePrimaryAmmo(1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:Throw(2000)
	self:SetNextPrimaryFire(CurTime()+3)
	self:SetNextSecondaryFire(CurTime()+3)
	return true;
end

function SWEP:Throw(vel)
	local e = ents.Create("wtib_sonicgrenade")
	e:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*50)
	e:SetAngles(self.Owner:GetAimVector())
	e.WDSO = self.Owner
	e.WDSE = self
	e:Spawn()
	e:Activate()
	local phys = e:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(true)
		phys:SetVelocity(self:GetOwner():GetAimVector()*vel)
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	self:TakePrimaryAmmo(1)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:Throw(500)
	self:SetNextPrimaryFire(CurTime()+3)
	self:SetNextSecondaryFire(CurTime()+3)
	return true;
end
