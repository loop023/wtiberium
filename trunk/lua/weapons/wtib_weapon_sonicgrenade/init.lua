AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function SWEP:PrimaryAttack()
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	self:TakePrimaryAmmo(1)
	self:SendWeaponAnim(ACT_VM_THROW)
	timer.Simple(.7,function()
		self:SendWeaponAnim(ACT_VM_DRAW)
	end)
	self:Throw(1000)
	self:SetNextPrimaryFire(CurTime()+1.7)
	self:SetNextSecondaryFire(CurTime()+1.7)
	return true
end

function SWEP:Throw(vel)
	local e = ents.Create("wtib_sonicgrenade")
	e:SetPos(self.Owner:EyePos()+(self.Owner:GetAimVector()*16))
	e:SetAngles(self.Owner:GetAimVector())
	e.WDSO = self.Owner
	e.WDSE = self
	e:Spawn()
	e:Activate()
	local phys = e:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetVelocity(self.Owner:GetAimVector()*vel)
		phys:AddAngleVelocity(Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)))
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	self:TakePrimaryAmmo(1)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	timer.Simple(.7,function()
		if self and self:IsValid() then
			self:SendWeaponAnim(ACT_VM_DRAW)
		end
	end)
	self:Throw(400)
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
	return true
end
