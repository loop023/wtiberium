AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(20,220,20,255)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_seeder")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Explode(missile,data)
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	util.Effect("SeederExplosion",ed)
	local tr = util.QuickTrace(missile:GetPos(),data.HitPos,{missile,missile.FTrail})
	if !tr.Hit or tr.HitSky then missile:Remove() return end
	local e = ents.Create("wtib_greentiberium")
	local ang = tr.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(tr.HitPos)
	e:Spawn()
	e:Activate()
	for i=1,3 do
		e:EmitGas()
	end
	for i=1,6 do
		e:SetTiberiumAmount(3000)
		e:Reproduce()
	end
	e:SetTiberiumAmount(math.random(200,500))
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile:SetColor(20,220,20,255)
	return true
end
