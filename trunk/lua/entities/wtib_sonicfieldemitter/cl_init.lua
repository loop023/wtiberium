include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib_Render(self)
end

function ENT:WTib_GetTooltip()
	local on = "Off"
	if self:GetNWBool("Online") then
		on = "On"
	end
	return "Sonic Field Emitter ("..on..")\nRadius : "..tostring(self:GetNWInt("Radius"))
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
		self.NextRBUpdate = CurTime()+2
		WTib_UpdateRenderBounds(self)
	end
end
language.Add("wtib_sonicfieldemitter","Sonic Field Emitter")