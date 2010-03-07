
SWEP.Base					= "wtib_swep_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel				= "models/weapons/w_physics.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.Recoil			= 1.8
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 16
SWEP.Primary.Delay			= 0.05
SWEP.Primary.DefaultClip	= 21
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.LastCharge				= 0
SWEP.ChargeSound			= Sound("")
SWEP.ShootSound				= Sound("")

function SWEP:SetupDataTables()
	self:DTVar("Bool",0,"Ironsights")
	self:DTVar("Float",0,"LastShootTime")
	self:DTVar("Float",1,"Charge")
end

function SWEP:Reload() end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

function SWEP:Think()
	if !IsValid(self.Owner) then return end
	if self.Owner:KeyPressed(IN_ATTACK) then
		self:EmitSound(self.ChargeSound)
		self.dt.Charge = 1
	elseif self.Owner:KeyDown(IN_ATTACK) then
		if self.LastCharge+0.1 <= CurTime() then
			self.dt.Charge = math.Clamp(self.dt.Charge+1,1,100)
			self.LastCharge = CurTime()
		end
	elseif self.Owner:KeyReleased(IN_ATTACK) then
		self:FireWeapon()
	end
end

function SWEP:FireWeapon()
	self:StopSound(self.ChargeSound)
	self:EmitSound(self.ShootSound)
	if SERVER then
		local Origin = self.Owner:GetShootPos()
		local Target = self.Owner:GetAimVector()
		local Charge = self.dt.Charge
		for i=1,5 do
			timer.Simple(i/6,function()
				local Dist = 25*i
				for _,v in pairs(ents.FindInCone(Origin,Target,Dist,10)) do
					if v.IsTiberium then
						local Dam = (Dist-Origin:Distance(v:GetPos()))*(Charge/10)
						if Dam < 0 then Dam = -Dam end
						v:TakeSonicDamage(Dam)
					end
				end
			end)
		end
	end
	self.dt.Charge = 0
end
