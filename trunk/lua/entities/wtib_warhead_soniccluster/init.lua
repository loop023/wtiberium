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
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_soniccluster")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Explode(missile,data)
	local pos = missile:GetPos()
	local WDSO = self.WDSO or self
	local WDSE = self
	util.BlastDamage(WDSE,WDSO,pos,math.random(100,200),math.random(200,300))
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	ed:SetScale(3)
	util.Effect("Explosion",ed)
	missile:Remove()
	for i=1,8 do
		local e = ents.Create("wtib_sonicgrenade")
		e:SetPos(pos)
		e.WDSO = WDSO or WDSE
		e.WDSE = WDSE
		e.DetTime = math.Rand(1.8,2.2)
		e:Spawn()
		e:Activate()
		local phys = e:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddVelocity(VectorRand()*800)
		end
	end
end
