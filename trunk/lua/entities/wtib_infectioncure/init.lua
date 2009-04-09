AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/HealthKit.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(170,255,170,255)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_infectioncure")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Touch(data,ply)
	self:Heal(ply)
end

function ENT:Heal(ply)
	if ply and ply:IsValid() and ply:IsPlayer() then
		WTib_CureInfection(ply)
		ply:EmitSound("sound/items/medshot4.wav")
		if ply:Health() < 100 then
			ply:SetHealth(math.Clamp(ply:Health()+20,1,100))
		end
		self:Remove()
	end
end

function ENT:Use(ent)
	self:Heal(ply)
end
