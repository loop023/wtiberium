include('shared.lua')

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay				= self.AmmoDisplay or {}
	self.AmmoDisplay.Draw			= true
	self.AmmoDisplay.PrimaryClip 	= self.Weapon:GetNetworkedInt("ammo_clip_"..self.Ammo or "",0)
	self.AmmoDisplay.PrimaryAmmo 	= self.Weapon:GetNetworkedInt("ammo_"..self.Ammo or "",0)
	self.AmmoDisplay.SecondaryAmmo 	= self.Weapon:GetNetworkedInt("ammo_"..self.Ammo or "",0)
	return self.AmmoDisplay
end
language.Add("wtib_weapon_base","Tiberium SWep base")