include('shared.lua')

function ENT:WTib_GetTooltip()
	return "Tiberium Missile\nCurrent Warhead : "..tostring(self:GetNWString("Warhead","None"))
end
language.Add("wtib_missile","Missile")
