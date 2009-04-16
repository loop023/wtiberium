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
	data = data or {}
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	ed:SetScale(1)
	util.Effect("WTib_SeederExplosion",ed)
	local t = util.QuickTrace(missile:GetPos(),data.HitPos or missile:GetForward()*80,{missile,missile.FTrail})
	if (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then missile:Remove() return end
	local e = ents.Create("wtib_greentiberium")
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	e.WDSO = missile.WDSO
	e:Spawn()
	e:Activate()
	if t.Entity and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	for i=1,3 do
		print(i)
		e:EmitGas()
	end
	for i=1,6 do
		print(i)
		e:SetTiberiumAmount(3000)
		e:Reproduce()
	end
	for _,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
		if v.IsTiberium then
			local ed = EffectData()
			ed:SetOrigin(v:GetPos())
			ed:SetStart(v:GetPos())
			ed:SetScale(1)
			util.Effect("WTib_SeederExplosion",ed)
		end
	end
	e:SetTiberiumAmount(math.Rand(200,500))
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile:SetColor(20,220,20,255)
	return true
end
