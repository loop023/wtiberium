
SWEP.Author					= "kevkev/Warrior xXx"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= "Leftclick to create a sonic ray in front of you."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/v_rpg.mdl"
SWEP.WorldModel				= "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModelFlip			= false
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.PrintName				= "Sonic Ray"	
SWEP.Slot					= 4
SWEP.SlotPos				= 6
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.Category				= "Tiberium"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"
SWEP.NextFire				= 0

function SWEP:PrimaryAttack()
	if self.NextFire > CurTime() then return end
	local ed = EffectData()
	ed:SetEntity(self.Owner)
	ed:SetOrigin(self:GetShootPos())
	ed:SetAngles(self.Owner:GetAimVector())
	ed:SetScale(4)
	util.Effect("wtib_weapon_sonicray",ed)
	self.NextFire = CurTime()+0.5
end

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end
