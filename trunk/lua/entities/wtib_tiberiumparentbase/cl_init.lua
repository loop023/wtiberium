include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Size = 0

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	self:CreateDLight()
	self:NextThink(CurTime()+1)
	return true
end

function ENT:CreateDLight()
	if ((WTib_DynamicLight and !WTib_DynamicLight:GetBool()) or false) or !self.DynLight then return end
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		self.Size = math.Approach((self.Size or 0),math.Rand(400,600),10)
		local r,g,b,a = self:GetColor()
		dlight.Pos = self:GetPos()+self:GetUp()*30
		dlight.r = r
		dlight.g = g
		dlight.b = b
		dlight.Brightness = 1
		dlight.Size = self.Size
		dlight.Decay = self.Size*5
		dlight.DieTime = CurTime()+1
	end
end
language.Add("wtib_tiberiumparentbase",ENT.PrintName)
