
local Vect = Vector(0,0,0)

function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.Leng = data:GetMagnitude()
 	self.Emitter = ParticleEmitter(self.Ent:GetPos())
	self.Entity:SetRenderBounds(self.Ent:GetPos()*-self.Leng,self.Ent:GetPos()*self.Leng)
end

function EFFECT:Think()
	if !self.Ent or !self.Ent:IsValid() or !self.Ent:GetNWBool("Online") then
		if self.Emitter then
			self.Emitter:Finish()
		end
		return false
	else
		return true
	end
end

function EFFECT:Render()
	local part
	local StartPos = self.Ent:LocalToWorld(Vector(math.Rand(-90,90),math.Rand(-90,90),math.Rand(self.Leng-40,self.Leng+40)))
	if self.Emitter then
		part = self.Emitter:Add("particle/Particle_Glow_03.vtf",StartPos)
	end
	if part then
		part:SetColor(0,150,0,100)
		part:SetAirResistance(5)
		part:SetDieTime(1.5)
		part:SetGravity(Vect)
		part:SetVelocity((self.Ent:GetPos()-StartPos))
		part:SetLifeTime(0)
		part:SetRoll(self.Ent:GetAngles())
		part:SetRollDelta(0)
		part:SetStartSize(7)
		part:SetEndSize(0)
		part:SetStartAlpha(100)
		part:SetEndAlpha(0)
	end
end
