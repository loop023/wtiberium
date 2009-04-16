
EFFECT.Table = {}
EFFECT.Table[1] = Vector(1,0,0)
EFFECT.Table[2] = Vector(1,1,0)
EFFECT.Table[3] = Vector(0,0,1)
EFFECT.Table[4] = Vector(0,1,1)
EFFECT.Table[5] = Vector(1,0,1)
EFFECT.Table[6] = Vector(1,1,1)
EFFECT.Table[7] = Vector(-1,0,0)
EFFECT.Table[8] = Vector(-1,-1,0)
EFFECT.Table[9] = Vector(0,0,-1)
EFFECT.Table[10] = Vector(0,-1,-1)
EFFECT.Table[11] = Vector(-1,0,-1)
EFFECT.Table[12] = Vector(-1,-1,-1)

function EFFECT:Init(data)
	local pos = data:GetOrigin() or data:GetStart()
 	local e = ParticleEmitter(pos)
	local size = data:GetScale() or 1
	for i=1,5 do
		for k,v in pairs(self.Table) do
			local val = math.Rand(-1,10)
			local part
			if e then
				part = e:Add("particle/SmokeStack",pos+(v*val))
			end
			if part then
				part:SetColor(0,150,0,240)
				part:SetAirResistance(700/(size/1.5))
				part:SetDieTime(10)
				part:SetEndSize(200*size)
				part:SetEndAlpha(0)
				part:SetGravity(Vector(0,0,0))
				part:SetLifeTime(0)
				part:SetRoll(math.Rand(0,360))
				part:SetRollDelta(math.Rand(-0.1,0.1))
				part:SetStartAlpha(240)
				part:SetStartSize(20*size)
				part:SetVelocity(((v*val)*120)*size)
			end
		end
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
