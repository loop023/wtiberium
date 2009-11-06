include('shared.lua')

function ENT:WTib_GetTooltip()
	return self.PrintName.."\nEnergy : "..math.Round(tostring(self:GetNWInt("Energy",0))).."\nRefined Tiberium : "..math.Round(tostring(self:GetNWInt("RefTib",0))).."\nTiberium Chemicals : "..math.Round(tostring(self:GetNWInt("TibChem",0)))
end
language.Add("wtib_warhead_custom",ENT.PrintName)
