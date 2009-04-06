
local matRefraction = Material("refract_ring")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.aScale = data:GetScale() or 1
	self:SetRenderBoundsWS(self.Position,self:GetRight()*(200*self.aScale))
	self.Created = CurTime()
	self.LifeTime = 3
	self.Size = 0
	self.Refract = 0.5
	self.DeltaRefract = 0.06
	self.MaxSize = 4000*self.aScale
	if render.GetDXLevel() <= 81 then
		matRefraction = Material("effects/strider_pinch_dudv")
		self.Refract = 0.3
		self.DeltaRefract = 0.03
		self.MaxSize = 200*self.aScale
	end
end

function EFFECT:Think()
	local fTime = FrameTime()
	self.Refract = self.Refract-self.DeltaRefract*fTime
	self.Size = self.Size+(200*self.aScale)*fTime
	return (CurTime()-self.Created < self.LifeTime)
end

function EFFECT:Render()
	if self.Size < self.MaxSize then
		matRefraction:SetMaterialFloat("$refractamount",math.sin(self.Refract*math.pi)*0.2)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawQuadEasy(self.Position,Vector(0,0,1),self.Size,self.Size)
	end
end
