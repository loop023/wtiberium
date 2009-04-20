
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
	local Pos = self.Owner:GetPos()
	local Ang = self.Owner:GetForward()
	local tab = {}
	print("Pos "..tostring(Pos)..", Ang "..tostring(Ang))
	Ang.z = 0
	print("Ang "..tostring(Ang))
	local Time = 0
	Pos = Pos+Ang*10
	print("Pos "..tostring(Pos))
	for i = 1,4 do
		print("Loop "..i)
		Pos = Pos+Ang*90
		print("Pos "..tostring(Pos))
		Time = Time+0.1
		print("Time "..tostring(Time))
		timer.Simple(Time,function()
			print("In timer number "..i)
			local ed = EffectData()
			ed:SetOrigin(Pos)
			ed:SetStart(Pos)
			print("Pos "..tostring(Pos))
			ed:SetMagnitude(80)
			ed:SetScale(10)
			ed:SetRadius(30)
			util.Effect("WTib_SonicSpike",ed)
			print("Effect created with data :")
			print(tostring(ed))
			local Ents = ents.FindInSphere(self:GetPos(),50)
			for k,v in pairs(Ents) do
				print("InSphere")
				if v.IsTiberium then
					print("Tib here")
					tab[k] = v.IgnoreExpBurDamage
					v.IgnoreExpBurDamage = true
				end
			end
			print("OutLoop")
			util.BlastDamage(self,self.Owner,Pos,30,25)
			for k,v in pairs(Ents) do
				if v.IsTiberium and tab[k] != nil then
					v.IgnoreExpBurDamage = tab[k]
				end
			end
			print("End of Timer")
		end)
		print("End of Loop")
	end
	print("End of Function")
	self.NextFire = CurTime()+(Time+0.1)
end

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end
