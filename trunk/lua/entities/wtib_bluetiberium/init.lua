AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.MaxTiberium = 3000
ENT.Divider = 12
ENT.r = 0
ENT.g = 0
ENT.b = 255

function ENT:Initialize()
	self:SetModel("models/props_gammarays/tiberium.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetColor(self.r,self.g,self.b,150)
	self:SetMaterial("models/debug/debugwhite")
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.NextProduce = CurTime()+math.random(30,60)
	self.NextGas = CurTime()+math.random(5,60)
	self:Think()
	self:SetTiberiumAmount(math.random(200,500))
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_bluetiberium")
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end
