AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/warhead.mdl")
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
	local t = util.QuickTrace(missile:GetPos(),data.HitPos or missile:GetForward()*160,{missile,missile.FTrail})
	if (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then missile:Remove() return end
	local e = WTib_CreateTiberiumByTrace(t,"wtib_greentiberium",missile.WDSO or missile)
	if !e or !e:IsValid() then
		t = util.QuickTrace(missile:GetPos(),missile:GetForward()*160,{missile,missile.FTrail})
		e = WTib_CreateTiberiumByTrace(t,"wtib_greentiberium",missile.WDSO or missile)
	end
	if e and e:IsValid() then
		for i=1,8 do
			timer.Simple(i/10,function()
				e:SetTiberiumAmount(3000)
				e:Reproduce()
			end)
		end
	end
	for _,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
		if v.IsTiberium then
			local ed = EffectData()
			ed:SetOrigin(v:GetPos())
			ed:SetStart(v:GetPos())
			ed:SetScale(1)
			util.Effect("WTib_SeederExplosion",ed)
			v:AddTiberiumAmount(math.Rand(50,100))
		end
	end
	timer.Simple(0.6,function()
		e:SetTiberiumAmount(math.Rand(200,500))
	end)
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile:SetColor(20,220,20,255)
	missile.WDSO = self.WDSO or missile.WDSO or missile
	return true
end
