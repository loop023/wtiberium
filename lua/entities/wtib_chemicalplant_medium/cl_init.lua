include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

function ENT:WTib_GetTooltip()
	local on = "Off"
	if self.dt.Online then
		on = "On"
	end
	return self.PrintName.." ("..on..")\nEnergy : "..math.Round(tostring(self.dt.Energy)).."\nRefined Tiberium : "..math.Round(tostring(self.dt.RefinedTiberium))
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(string.Replace(ENT.Folder,"entities/",""),ENT.PrintName)
