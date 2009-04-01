AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
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
	self:SetTiberiumAmount(math.random(20,50))
end

function ENT:SpawnFunction(p,t) end
