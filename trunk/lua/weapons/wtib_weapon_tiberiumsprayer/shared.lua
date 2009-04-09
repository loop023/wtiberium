
SWEP.Author					= "kevkev/Warrior xXx"
SWEP.Contact				= ""
SWEP.Purpose				= "Gassing people to death."
SWEP.Instructions			= "Rightclick on a device that uses refined tiberium to fill up your gas tank, left click to spray gas."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/v_rpg.mdl"
SWEP.WorldModel				= "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModelFlip			= false
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.PrintName				= "Tiberium Sprayer"	
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
SWEP.IsEmittingSound		= false
SWEP.Tiberium				= 1000

function SWEP:PrimaryAttack()
	if self.NextFire > CurTime() then return end
	local dr = math.Rand(10,20)
	if self.Tiberium >= dr then
		self.Tiberium = math.Clamp(self.Tiberium-dr,0,4000)
		if SERVER then
			local e = ents.Create("wtib_tiberiumgas")
			e:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*50)
			e:SetAngles(self.Owner:GetAimVector())
			e.WDSO = self.Owner
			e.WDSE = self
			e:SetStartColor(Color(0,120,0))
			e:SetEndColor(Color(0,255,0))
			e:SetSize(250)
			e:SetDamage(5)
			e:Spawn()
			e:Activate()
			e:GetPhysicsObject():EnableDrag(true)
			e:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector()*math.Rand(150,250))
			e:Fire("kill","",2)
		end
		if !self.IsEmittingSound then
			self:EmitSound("ambient.steam01")
			self.IsEmittingSound = true
		end
	elseif self.IsEmittingSound then
		self:StopSound("ambient.steam01")
		self.IsEmittingSound = false
	end
	self.NextFire = CurTime()+0.1
end

function SWEP:Think()
	if !self.Owner:KeyDown(IN_ATTACK) and self.IsEmittingSound then
		self:StopSound("ambient.steam01")
		self.IsEmittingSound = false
	end
	self:NextThink(CurTime()+0.1)
end

function SWEP:SecondaryAttack()
	local td = {}
	local st = self.Owner:GetShootPos()
	td.start = st
	td.endpos = st+(self.Owner:GetAimVector()*200)
	td.filter = self.Owner
	local tr = util.TraceLine(td)
	if tr.Entity and tr.Entity:IsValid() then
		local Amount = WTib_GetResourceAmount(tr.Entity,"RefinedTiberium")
		if Amount >= 50 and self.Tiberium < 4000 then
			self.Tiberium = math.Clamp(self.Tiberium+50,0,4000)
			if SERVER then
				WTib_ConsumeResource(tr.Entity,"Tiberium",Amount)
			end
		end
	end
end

function SWEP:Deploy()
	self.Owner.IsTiberiumResistant = true
end

function SWEP:Holster()
	self.Owner.IsTiberiumResistant = false
	return true
end
