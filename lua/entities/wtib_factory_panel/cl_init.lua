include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)
