
local BLaser = Material("wtiberium/tiberiumlaser/bluelight")
local RLaser = Material("wtiberium/tiberiumlaser/redlight")

function EFFECT:Init(data)
	self.Player		= data:GetEntity()
	self.StartPos	= self.Player:GetShootPos()
	self.EndPos		= data:GetOrigin()
	self.Mag		= data:GetMagnitude()
	self.Time		= CurTime()
	self.Size		= self.Time-CurTime()+0.5
end

function EFFECT:Think()
	if self.Player and self.Player:IsValid() then
		self.StartPos = self.Player:GetShootPos()
	end
	return (self.Time >= CurTime())
end

function EFFECT:Render()
	local mat = BLaser
	if self.Mag >= 30 then
		mat = RLaser
	end
	render.SetMaterial(mat)
	render.DrawBeam(self.StartPos,self.EndPos,(self.Time-CurTime())*2,0,0,Color(255,255,122.5,255))
end
