
local Vect = Vector(0,0,0)

EFFECT.LastPart = 0

function EFFECT:Init(data)
	local Origin = data:GetOrigin()
	local Col = data:GetAngle() // Color
 	self.Emitter = ParticleEmitter(Origin)
	self.Entity:SetRenderBounds(Origin*-60,Origin*60)
	for i=1,2 do
		local part
		if self.Emitter then
			part = self.Emitter:Add("particle/SmokeStack.vtf",Origin+Vector(math.Rand(-15,15),math.Rand(-15,15),math.Rand(-15,15)))
		end
		if part then
			part:SetColor(Col.p or 255,Col.y,Col.r or 0,100)
			part:SetAirResistance(5)
			part:SetDieTime(data:GetAttachment() or 2)
			part:SetGravity(Vect)
			part:SetVelocity(Vect)
			part:SetLifeTime(0)
			part:SetRoll(Angle(0,0,0))
			part:SetRollDelta(0)
			part:SetStartSize(40)
			part:SetEndSize(10)
			part:SetStartAlpha(178)
			part:SetEndAlpha(0)
		end
	end
	if self.Emitter then
		self.Emitter:Finish()
	end
end

function EFFECT:Think()
	return true
end

function EFFECT:Render()
end
