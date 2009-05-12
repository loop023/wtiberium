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
	if !self.En or !self.RefTib or !self.TibChem then
		self:SetValues()
	end
	self:SetNWInt("Energy",self.En or 50)
	self:SetNWInt("RefTib",self.RefTib or 10)
	self:SetNWInt("TibChem",self.TibChem or 0)
	self:NextThink(CurTime()+10)
	return true
end

function ENT:SetValues(En,RefTib,TibChem)
	self.En = En or self.En or 50
	self.RefTib = RefTib or self.RefTib or 10
	self.TibChem = TibChem or self.TibChem or 0
	self:SetNWInt("Energy",self.En or 50)
	self:SetNWInt("RefTib",self.RefTib or 10)
	self:SetNWInt("TibChem",self.TibChem or 0)
	self:SetColor(math.Clamp((self.RefTib/10)+55,55,255),math.Clamp((self.TibChem/5)+55,55,255),math.Clamp((self.En/15)+55,55,255),255)
end

function ENT:Explode(missile,data)
	data = data or {}
	util.BlastDamage(missile,missile.WDSO,data.HitPos or missile:GetPos(),missile.RefTib or 10,missile.En or 50)
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	ed:SetScale((missile.RefTib or 10)/10)
	util.Effect("Explosion",ed)
	if missile.TibChem >= 800 then
		for _,v in pairs(ents.FindInSphere(data.HitPos or missile:GetPos(),missile.RefTib/1.2)) do
			if v.IsTiberium then
				v:AddTiberiumAmount(math.Rand(50,100))
			elseif v:IsNPC() or v:IsPlayer() then
				WTib_InfectLiving(v,self)
			elseif v:GetClass() == "prop_ragdoll" then
				WTib_RagdollToTiberium(v)
			elseif v != missile and v != missile.FTrail and v:IsValid() and !v:IsWeapon() and !v:IsWorld() and v:GetPhysicsObject():IsValid() and string.find(v:GetClass(), "func_") != 1 and v:GetClass() != "physgun_beam" then
				WTib_PropToTiberium(v)
			end
		end
	end
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile.En = tonumber(self.En or 50)
	missile.RefTib = tonumber(self.RefTib or 10)
	missile.TibChem = tonumber(self.TibChem or 0)
	missile.WDSO = self.WDSO or missile.WDSO or missile
	missile:SetColor(math.Clamp((self.RefTib/10)+55,55,255),math.Clamp((self.TibChem/5)+55,55,255),math.Clamp((self.En/15)+55,55,255),255)
	return true
end
