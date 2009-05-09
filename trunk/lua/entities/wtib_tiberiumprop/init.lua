AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(self.r,self.g,self.b,150)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.NextProduce = CurTime()+math.Rand(30,60)
	self.NextGas = CurTime()+math.Rand(5,60)
	self:Think()
	self:SetTiberiumAmount(math.Rand(20,50))
end

function ENT:SecThink()
	if self:GetTiberiumAmount() <= 0 then
		local e = ents.Create(self.Class)
		if !e and !e:IsValid() then self:Remove() return end
		e:SetPos(self:GetPos())
		e:SetModel(self:GetModel())
		e:SetAngles(self:GetAngles())
		e:SetColor(self:GetColor())
		e:SetSkin(self:GetSkin())
		e.Class = e:GetClass()
		if self.ZatMode == 1 then -- Zat compatability
			e.ZatMode = 2
			e.LastZat = self.LastZat or CurTime()
		end
		e:Spawn()
		e:Activate()
		self:Remove()
	end
end
