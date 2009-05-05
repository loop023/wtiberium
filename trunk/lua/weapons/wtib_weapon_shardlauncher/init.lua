AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

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
	return true
end
