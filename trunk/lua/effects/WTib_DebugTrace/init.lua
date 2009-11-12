
EFFECT.Mat = Material("cable/redlaser")

function EFFECT:Init(d)
	self.StartPos = d:GetStart()	
	self.EndPos = d:GetOrigin()
	self.Dir = self.EndPos-self.StartPos
	self.fDelta = 3
	self.Entity:SetRenderBoundsWS(self.StartPos,self.EndPos)
	self.DieTime = CurTime()+d:GetMagnitude()
end

function EFFECT:Think()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	if !WTib_Debug then return end
	self.fDelta = math.Max(self.fDelta-0.5,0)
	render.SetMaterial(self.Mat)
	render.DrawBeam(self.EndPos,self.StartPos,2+self.fDelta*16,0,0,Color(255,0,0,255))
end
