
local BLaser = Material("wtiberium/tiberiumlaser/bluelight")

function EFFECT:Init(data)
	self.EndPos		= data:GetOrigin()
	self.Time		= CurTime()+(data:GetMagnitude()/10)
	self.Ent		= data:GetEntity()
	self.StartPos = self.Ent:GetActiveWeapon():GetAttachment(1).Pos
	if self.Ent == LocalPlayer() then
		self.StartPos = LocalPlayer():GetViewModel():GetAttachment(1).Pos
	end
end

function EFFECT:Think()
	return (self.Time >= CurTime())
end

function EFFECT:Render()
	render.SetMaterial(BLaser)
	render.DrawBeam(self.StartPos,self.EndPos,(self.Time-CurTime())*2,0,0,Color(255,255,122.5,255))
end
