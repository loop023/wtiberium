AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

SWEP.ClipSize = 30
SWEP.NextFire = 0
SWEP.InReload = false

function SWEP:Initialize()
	self:SetWeaponHoldType("smg")
	self:SetNetworkedInt("ammo_clip_tiberiumshards",self.ClipSize)
end

function SWEP:PrimaryAttack()
	if self.NextFire > CurTime() or self.InReload then return false end
	if self:GetNetworkedInt("ammo_clip_tiberiumshards",0) <= 0 then
		self:Reload()
		return false
	end
	self.NextFire = CurTime()+.15
	self:DoPrimaryAttack()
	self:SetNetworkedInt("ammo_clip_tiberiumshards",self:GetNetworkedInt("ammo_clip_tiberiumshards")-1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	return true
end

function SWEP:DoPrimaryAttack()
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

function SWEP:SecondaryAttack()
	self:DoSecondaryAttack()
end

function SWEP:DoSecondaryAttack()
	self:PrimaryAttack()
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
		local val = ply:GetNetworkedInt("ammo_tiberiumshards",0)
		ply:SetNetworkedInt("ammo_tiberiumshards",math.Clamp(val+100,100,500))
	end
end

function SWEP:Reload()
	local clip = self:GetNetworkedInt("ammo_clip_tiberiumshards")
	if clip >= 30 or self.InReload or self.Owner:GetNetworkedInt("ammo_tiberiumshards") <= 0 then return end
	self:SendWeaponAnim(ACT_VM_RELOAD)
	local ammo = self.Owner:GetNetworkedInt("ammo_tiberiumshards")
	local val = math.Clamp(self.ClipSize-clip,0,ammo)
	self:SetNetworkedInt("ammo_clip_tiberiumshards",clip+val)
	self.Owner:SetNetworkedInt("ammo_tiberiumshards",ammo-val)
	self.ReloadTime = CurTime()+2
	self.InReload = true
end
