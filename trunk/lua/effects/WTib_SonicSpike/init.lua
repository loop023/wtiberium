
EFFECT.Sound = Sound("ambient/fire/gascan_ignite1.wav")

function EFFECT:Init(data)
	local ed = EffectData()
	ed:SetOrigin(data:GetOrigin())
	ed:SetMagnitude(data:GetMagnitude())
	ed:SetScale(data:GetScale())
	ed:SetRadius(data:GetRadius())
	util.Effect("AR2Explosion",ed)
	self:EmitSound(self.Sound)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
