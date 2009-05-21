include('shared.lua')

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay				= self.AmmoDisplay or {}
	self.AmmoDisplay.Draw			= true
	self.AmmoDisplay.PrimaryClip 	= self.Weapon:GetNetworkedInt("Tiberium",0)
	self.AmmoDisplay.PrimaryAmmo 	= -1
	self.AmmoDisplay.SecondaryAmmo 	= -1
	return self.AmmoDisplay
end
language.Add("wtib_weapon_tiberiumlaser","Tiberium laser")
