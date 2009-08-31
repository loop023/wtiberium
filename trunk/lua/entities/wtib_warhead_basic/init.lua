AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/warhead.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(255,255,255,255)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_basic")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Explode(missile,data)
	data = data or {}
	util.BlastDamage(missile,missile.WDSO or missile,data.HitPos or missile:GetPos(),math.Rand(200,300),math.Rand(300,400))
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	ed:SetScale(3)
	util.Effect("Explosion",ed)
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile:SetColor(255,255,255,255)
	missile.WDSO = self.WDSO or missile.WDSO or missile
	return true
end
