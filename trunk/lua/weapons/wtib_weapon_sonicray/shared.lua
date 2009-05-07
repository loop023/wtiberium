
SWEP.Author					= "kevkev/Warrior xXx"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= "Leftclick to create a sonic ray in front of you."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel				= "models/Weapons/w_physics.mdl"
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
	Ang.z = 0
	local Time = 0
	Pos = Pos+Ang*10
	for i = 1,5 do
		Pos = Pos+Ang*70
		Time = Time+.1
		timer.Simple(Time,self.MakeSpike,self,Pos)
	end
	self.NextFire = CurTime()+(Time+.5)
end

function SWEP:MakeSpike(Pos)
	local t = util.QuickTrace(Pos,Pos+Vector(0,0,-10000),{self.Owner,self})
	if !t.Hit then return end
	local ed = EffectData()
	ed:SetOrigin(t.HitPos)
	ed:SetNormal(t.HitNormal)
	ed:SetStart(t.HitPos)
	ed:SetMagnitude(80)
	ed:SetScale(10)
	ed:SetRadius(30)
	util.Effect("WTib_SonicSpike",ed)
	if SERVER then
		local Ents = ents.FindInSphere(t.HitPos,50)
		local tab = {}
		for k,v in pairs(Ents) do
			if v.IsTiberium then
				tab[k] = v.IgnoreExpBurDamage
				v.IgnoreExpBurDamage = true
			end
		end
		util.BlastDamage(self,self.Owner,t.HitPos,30,25)
		for k,v in pairs(Ents) do
			if v and v:IsValid() and tab[k] != nil then
				v.IgnoreExpBurDamage = tab[k]
				v:TakeSonicDamage(math.Rand(50,300))
			end
		end
	end
end

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end
