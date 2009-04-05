include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	self:CreateDLight()
	self:NextThink(CurTime()+1)
	return true
end

function ENT:CreateDLight()
	if WTIBERIUM_NODYNAMICLIGHT or !self.DynLight then return end
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		local size = (self:GetNWInt("TiberiumAmount")/7)+100
		local r,g,b,a = self:GetColor()
		dlight.Pos = self:GetPos()+self:GetUp()*30
		dlight.r = r
		dlight.g = g
		dlight.b = b
		dlight.Brightness = 1
		dlight.Size = size
		dlight.Decay = size*5
		dlight.DieTime = CurTime()+1
	end
end
language.Add("wtib_tiberiumbase","Base Tiberium")
