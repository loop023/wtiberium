AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/HealthKit.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
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

function ENT:Touch(ply)
	self:Heal(ply)
end

function ENT:Heal(ply)
	if ply:IsPlayer() and (ply:Health() < 100 or WTib_IsInfected(ply)) then
		WTib_CureInfection(ply)
		ply:EmitSound("items/medshot4.wav")
		if ply:Health() < 100 then
			ply:SetHealth(math.Clamp(ply:Health()+20,1,100))
		end
		self:Remove()
	end
end

function ENT:Use(ply)
	self:Heal(ply)
end
