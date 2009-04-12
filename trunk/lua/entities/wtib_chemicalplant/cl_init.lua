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
	return "Tiberium Checmical Plant ("..on..")\nEnergy : "..math.Round(tostring(self:GetNWInt("energy",0))).."\nTiberium : "..math.Round(tostring(self:GetNWInt("Tib",0))).."\nTiberium Chemicals : "..math.Round(tostring(self:GetNWInt("TibChem",0)))
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
		self.NextRBUpdate = CurTime()+2
		WTib_UpdateRenderBounds(self)
	end
end
language.Add("wtib_chemicalplant","Tiberium Chemical Plant")
