AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/warhead.mdl")
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

function ENT:DuringFlight(missile)
	if !self.Armed then return end
	if missile.Target and missile.Target != Vector(0,0,0) then
		if missile:GetPos():Distance(missile.Target) <= 500 then
			missile:Explode(missile)
		end
	else
		local tr = util.QuickTrace(missile:GetPos(),missile:GetForward()*500,{missile,missile.FTrail})
		if tr.Hit then
			missile:Explode(missile)
		end
	end
end

function ENT:Explode(missile,data)
	data = data or {}
	local pos = missile:GetPos()
	local WDSO = self.WDSO or self
	local WDSE = self
	util.BlastDamage(WDSE,WDSO,pos,math.Rand(100,200),math.Rand(200,300))
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
			phys:AddVelocity(missile:GetVelocity()+(VectorRand()*300))
		end
	end
end
