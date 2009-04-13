include('shared.lua')

function ENT:WTib_GetTooltip()
	if self:GetNWBool("Armed",false) then return "" end
	return "Tiberium Missile\nCurrent Warhead : "..tostring(self:GetNWString("Warhead","None"))
end
language.Add("wtib_missile","Missile")
