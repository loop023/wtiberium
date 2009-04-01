
local matRefraction = Material("refract_ring")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Created = CurTime()
	self.LifeTime = 3
end

function EFFECT:Think()
	self.Size = self.Size+2e4*FrameTime()
	return (CurTime() - self.Created < self.LifeTime)
end

function EFFECT:Render()
	if self.Size < self.MaxSize then
		matRefraction:SetMaterialFloat("$refractamount",math.sin(self.Refract*math.pi)*0.2)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawQuadEasy(self.Position,Vector(0,0,1),self.Size,self.Size)
	end
end
