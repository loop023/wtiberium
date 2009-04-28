include('shared.lua')

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay				= self.AmmoDisplay or {}
	self.AmmoDisplay.Draw			= true
	self.AmmoDisplay.PrimaryClip 	= self.Weapon:GetNetworkedInt("ammo_clip_tiberiumshards",0)
	self.AmmoDisplay.PrimaryAmmo 	= self.Weapon:GetNetworkedInt("ammo_tiberiumshards",0)
	self.AmmoDisplay.SecondaryAmmo 	= -1
	return self.AmmoDisplay
end
language.Add("wtib_weapon_shardlauncher","Tiberium shard launcher")