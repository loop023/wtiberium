AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextDamage = 0

function ENT:Initialize()
	self:SetModel("models/items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_NONE)
	self:SetColor(0,0,0,0)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
	end
	self:Fire("kill","",2)
	local ed = EffectData()
		ed:SetAngle(Angle(self.Ent:GetColor())) // Color
		ed:SetOrigin(self:GetPos())
	util.Effect("WTib_GasEffect",ed)
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

function ENT:SetTiberium(e)
	self.Ent = e
end

function ENT:Think()
	if self.NextDamage <= CurTime() then
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self.Size or 60)) do
			if (v:IsPlayer() or v:IsNPC()) and !v.IsTiberiumResistant then
				v:TakeDamage(math.Rand(1,5),self.WDSO or self,self.WDSE or self.WDSO or self)
				v.WTib_InfectLevel = (v.WTib_InfectLevel or 0)+1
				if v.WTib_InfectLevel >= 10 then
					WTib_InfectLiving(v,self)
				end
			end
		end
		self.NextDamage = CurTime()+1
	end
	self:NextThink(CurTime())
	return true
end
