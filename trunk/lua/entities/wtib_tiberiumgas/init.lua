AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Size = 250
ENT.SRed = 120
ENT.SGreen = 0
ENT.SBlue = 0
ENT.ERed = 255
ENT.EGreen = 0
ENT.EBlue = 0
ENT.Damage = 3

function ENT:Initialize()
	self:SetModel("models/items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_NONE)
	self:SetColor(0,200,30,0)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
	end
	local e = ents.Create("env_smoketrail")
	e:SetAngles(self:GetAngles())
	e:SetPos(self:GetPos())
	e:SetParent(self)
	e:SetKeyValue("startcolor",self.SRed.." "..self.SGreen.." "..self.SBlue)
	e:SetKeyValue("endcolor",self.ERed.." "..self.EGreen.." "..self.EBlue)
	e:SetKeyValue("startsize","60")
	e:SetKeyValue("endsize","10")
	e:SetKeyValue("lifetime","2")
	e:SetKeyValue("opacity",".3")
	e:Spawn()
	e:Activate()
	self.Gas = e
	self.NextDamage = CurTime()
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_tiberiumgas")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:SetSize(a)
	self.Size = a
end

function ENT:SetStartColor(c)
	self.SRed = c.r
	self.SGreen = c.g
	self.SBlue = c.b
end

function ENT:SetEndColor(c)
	self.ERed = c.r
	self.EGreen = c.g
	self.EBlue = c.b
end

function ENT:OnRemove()
	if self.Gas and self.Gas:IsValid() then
		self.Gas:Remove()
	end
end

function ENT:SetDamage(a)
	self.Damage = math.Clamp(a,3,9999999)
end

function ENT:Think()
	if self.NextDamage <= CurTime() then
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self.Size or 250)) do
			if (v:IsPlayer() or v:IsNPC()) and !v.IsTiberiumResistant then
				v:TakeDamage(math.Rand(self.Damage-2,self.Damage+2),self.WDSO or self,self.WDSE or self)
			end
		end
		self.NextDamage = CurTime()+1
	end
	self:NextThink(CurTime())
	return true
end
