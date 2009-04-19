
function EFFECT:Init(data)
	local pos = data:GetOrigin() or data:GetStart()
	local col = Color(240,0,0,240)
	if data:GetEntity() and data:GetEntity():IsValid() then
		col = data:GetEntity():GetColor()
	end
 	local e = ParticleEmitter(pos)
	local size = data:GetScale() or 1
	local part
	if e then
		part = e:Add("particle/SmokeStack",pos)
	end
	if part then
		part:SetColor(col)
		part:SetAirResistance(0)
		part:SetDieTime(2)
		part:SetEndSize(50*size)
		part:SetEndAlpha(0)
		part:SetGravity(Vector(0,0,0))
		part:SetLifeTime(0)
		part:SetRoll(math.Rand(0,360))
		part:SetRollDelta(math.Rand(-0.1,0.1))
		part:SetStartAlpha(240)
		part:SetStartSize(4*size)
		part:SetVelocity(Vector(0,0,0))
	end
 	if e then
		e:Finish()
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
