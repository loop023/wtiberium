AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiberium_warhead.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(150,150,20,255)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_thermonium")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:OnTakeDamage()
	--self:Explode(self,{HitPos=self:GetPos()})
end

function ENT:Explode(missile,data)
	data = data or {}
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	util.Effect("TermoniumExplosion",ed)
	local rad = math.Rand(450,550)
	util.BlastDamage(missile,missile.WDSO or missile,data.HitPos or missile:GetPos(),rad,math.Rand(200,300))
	for _,v in pairs(ents.FindInSphere(data.HitPos or self:GetPos(),rad-10)) do
		if v.IsTiberium then
			v:AddTiberiumAmount(math.Rand(50,100))
		else
			v:Ignite()
		end
		if v:GetClass() == "prop_ragdoll" then
			WTib_RagdollToTiberium(v)
		elseif v:IsPlayer() or v:IsNPC() then
			WTib_InfectLiving(v,self)
		end
	end
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile:SetColor(150,150,20,255)
	missile.WDSO = self.WDSO or missile.WDSO or missile
	return true
end
