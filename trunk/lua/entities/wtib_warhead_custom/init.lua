AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:Think()
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_custom")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWInt("Energy",self.En)
	self:SetNWInt("RefTib",self.RefTib)
	self:SetNWInt("TibChem",self.TibChem)
	self:NextThink(CurTime()+10)
	return true
end

function ENT:Explode(missile,data)
	data = data or {}
	util.BlastDamage(missile,missile.WDSO,data.HitPos or missile:GetPos(),missile.RefTib,missile.En)
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	ed:SetScale(missile.RefTib/10)
	util.Effect("Explosion",ed)
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile.En = self.En
	missile.RefTib = self.RefTib
	missile.TibChem = self.TibChem
	return true
end
