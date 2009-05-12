AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextDamage = 0
ENT.HasHit = false

function ENT:Initialize()
	self:SetModel("models/Gibs/furniture_gibs/furniture_vanity01a_shard01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:Wake()
	end
	self.DieTime = CurTime()+60
end

function ENT:OnTakeDamage()
	return false
end

function ENT:PhysicsCollide(data,phys)
	if data.HitEntity and data.HitEntity:IsValid() and !data.HitEntity:IsWorld() then
		data.HitEntity:TakeDamage(5,self.WDSO or self,self.WDSE or self)
	end
	self:Remove()
	/*
	if data.HitEntity:IsNPC() or (data.HitEntity:IsPlayer() and data.HitEntity:Alive()) then
		self:SetPos(data.HitPos+(self:GetForward()*2))
		self:SetParent(data.HitEntity)
		constraint.Weld(self,data.HitEntity,0,0,0,true)
		self.HitEnt = data.HitEntity
		self.HasHit = true
	else
		self:Remove()
	end
	*/
end
/*
function ENT:Think()
	if !self.HasHit then return end
	if self.HitEnt and self.HitEnt:IsValid() then
		if self.NextDamage <= CurTime() then
			self.HitEnt:TakeDamage(1,self.WDSO or self,self.WDSE or self)
			self.NextDamage = CurTime()+2
			self.HitEnt.WTib_InfectLevel = (self.HitEnt.WTib_InfectLevel or 0)+1
			if self.HitEnt.WTib_InfectLevel >= 10 then
				WTib_InfectLiving(self.HitEnt,self)
			end
		end
	else
		self:Remove()
	end
end
*/