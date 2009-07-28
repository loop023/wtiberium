
local BLaser = Material("wtiberium/tiberiumlaser/bluelight")

function EFFECT:Init(data)
	self.StartPos	= data:GetStart()
	self.EndPos		= data:GetOrigin()
	self.Size		= CurTime()+data:GetMagnitude()
	if LocalPlayer():GetShootPos() == self.EndPos then
		--self.EndPos = WeaponShootPos
	end
end

function EFFECT:Think()
	return (self.Time >= CurTime())
end

function EFFECT:Render()
	render.SetMaterial(BLaser)
	render.DrawBeam(self.StartPos,self.EndPos,(self.Time-CurTime())*2,0,0,Color(255,255,122.5,255))
end
