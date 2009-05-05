AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType or "pistol")
	self:SetNetworkedInt("ammo_clip_"..self.Ammo or "",self.ClipSize)
	self:SetNetworkedInt("ammo_"..self.SecAmmo or "",self.SecClipSize)
end

function SWEP:PrimaryAttack()
	if self.NextFire > CurTime() or self.InReload then return false end
	if self:GetNetworkedInt("ammo_clip_"..self.Ammo or "",0) <= 0 then
		self:Reload()
		return false
	end
	self.NextFire = CurTime()+self.PrimeDelay
	self:PrimaryFire()
	self:SetNetworkedInt("ammo_clip_"..self.Ammo or "",self:GetNetworkedInt("ammo_clip_"..self.Ammo or "")-1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	return true
end

function SWEP:SecondaryAttack()
	if self.Ammo == self.SecAmmo then return self:PrimaryAttack() end
	if self.NextFire > CurTime() or self.InReload then return false end
	if self:GetNetworkedInt("ammo_"..self.SecAmmo or "",0) <= 0 then
		return false
	end
	self.NextFire = CurTime()+self.SecDelay
	self:SecondaryFire()
	self:SetNetworkedInt("ammo_"..self.SecAmmo or "",self:GetNetworkedInt("ammo_"..self.SecAmmo or "")-1)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	return true
end

function SWEP:SecondaryFire()
	self:PrimaryFire()
end

function SWEP:PrimaryFire()
	local e = ents.Create("wtib_shardshell")
	e:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*50)
	e:SetAngles(self.Owner:GetAimVector():Angle()+Angle(0,90,0))
	e.WDSO = self.Owner
	e.WDSE = self
	e:SetOwner(self.Owner)
	e:Spawn()
	e:Activate()
	local phys = e:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableDrag(true)
		phys:SetVelocity(self:GetOwner():GetAimVector()*2000)
	end
end

function SWEP:Think()
	if self.InReload then
		if self.ReloadTime <= CurTime() then
			self.InReload = false
			self.ReloadTime = 0
		end
	end
end

function SWEP:Equip(ply)
	self:EquipAmmo(ply)
end

function SWEP:EquipAmmo(ply)
	if ply and ply:IsValid() then
		local val = ply:GetNetworkedInt("ammo_"..self.Ammo or "",0)
		ply:SetNetworkedInt("ammo_"..self.Ammo or "",math.Clamp(val+self.ClipSize*3,self.ClipSize*3,self.ClipSize*15))
	end
end

function SWEP:Reload()
	local clip = self:GetNetworkedInt("ammo_clip_"..self.Ammo or "")
	local ammo = self.Owner:GetNetworkedInt("ammo_"..self.Ammo or "")
	if clip >= 30 or self.InReload or ammo <= 0 then return end
	self:SendWeaponAnim(ACT_VM_RELOAD)
	local val = math.Clamp(self.ClipSize-clip,0,ammo)
	self:SetNetworkedInt("ammo_clip_"..self.Ammo or "",clip+val)
	self.Owner:SetNetworkedInt("ammo_"..self.Ammo or "",ammo-val)
	self.ReloadTime = CurTime()+self.ReloadTime
	self.InReload = true
end
