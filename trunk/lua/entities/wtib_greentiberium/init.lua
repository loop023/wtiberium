AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

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
	if !t.Hit or (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC())) then return end
	local e = ents.Create("wtib_greentiberium")
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	if t.Entity and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	for i=1,3 do
		e:EmitGas()
	end
	return e
end