AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/grenadeAmmo.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	timer.Simple(5,function() self:Explode() end)
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_sonicgrenade")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Explode(ent)
	for _,v in pairs(ents.FindInSphere(self:GetPos(),300)) do
		if v.IsTiberium then
			v:DrainTiberiumAmount(math.Rand(500,1500))
		end
	end
	local ed = EffectData()
	ed:SetOrigin(ent:GetPos())
	ed:SetStart(ent:GetPos())
	ed:SetScale(3)
	util.Effect("SonicExplosion",ed)
	ent:Remove()
end
