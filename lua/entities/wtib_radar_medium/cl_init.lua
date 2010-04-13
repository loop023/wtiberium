include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	local On = "Off"
	if self.dt.Online then
		On = "On"
	end
	return self.PrintName.." ("..On..")\nHas Target : "..tostring(self.dt.HasTarget).."\nEnergy : "..math.Round(tostring(self.dt.Energy))
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)
