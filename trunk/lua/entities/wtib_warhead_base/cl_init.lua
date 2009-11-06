include('shared.lua')

function ENT:WTib_GetTooltip()
	return self.PrintName or ""
end
language.Add("wtib_warhead_base",ENT.PrintName)
