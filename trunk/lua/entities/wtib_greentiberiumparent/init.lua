AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_gammarays/tiberiumtower5.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:SecInit()
end

function ENT:SpawnFunction(p,t)
	p:PrintMessage(HUD_PRINTCENTER,"THIS IS A BETA DON'T COMPLAIN ABOUT BUGS!")
	p:ChatPrint("THIS IS A BETA DON'T COMPLAIN ABOUT BUGS!")
	return WTib_CreateTiberiumByTrace(t,self.Class,p)
end
