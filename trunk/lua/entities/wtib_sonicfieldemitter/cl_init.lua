include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	Wire_Render(self)
	local tr = LocalPlayer():GetEyeTrace()
	local on = "Off"
	if self:GetNWBool("Online") then
		on = "On"
	end
	if tr.Hit and tr.Entity and tr.Entity == self then
		AddWorldTip(self:EntIndex(),"Sonic Field Emitter ("..on..")\nRadius : "..tostring(self:GetNWInt("Radius")),0.5,tr.HitPos,self)
	end
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
	    self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self)
	end
end
language.Add("wtib_sonicfieldemitter","Sonic Field Emitter")