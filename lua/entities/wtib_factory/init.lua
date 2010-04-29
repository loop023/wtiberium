AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.LastBuild = 0

function ENT:Initialize()
	self:SetModel("models/Spacebuild/medbridge2_emptyhull.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"IsBuilding"})
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,13,self)
end

function ENT:Think()
	if self.dt.IsBuilding and self.LastBuild+self.Objects[self.dt.BuildingID].PercentDelay <= CurTime() then
		self.dt.PercentageComplete = self.dt.PercentageComplete+1
		if self.dt.PercentageComplete >= 100 then
			self.Objects[self.dt.BuildingID].CreateEnt(self,self.dt.CurObject:GetAngles(),self.dt.CurObject:GetPos(),self.dt.BuildingID)
			self.dt.CurObject:Remove()
			self.dt.IsBuilding = false
		end
		self.LastBuild = CurTime()
	end
	if !ValidEntity(self.PlayerUsingMe) then
		self.BeingUsed = false
		self.PlayerUsingMe = nil
	end
	self:NextThink(CurTime())
	return true
end

function ENT:Use(ply)
	if !self.BeingUsed then
		umsg.Start("wtib_factory_openmenu",ply)
			umsg.Entity(self)
		umsg.End()
		self.PlayerUsingMe = ply
		self.BeingUsed = true
	end
end

function ENT:BuildObject(id)
	if !self.dt.IsBuilding and self.Objects[id] then
		self.dt.BuildingID = id
		self.dt.PercentageComplete = 0
		self.dt.IsBuilding = true
		self.dt.CurObject = ents.Create("wtib_factory_object")
		self.dt.CurObject:SetAngles(self:GetAngles())
		self.dt.CurObject:SetModel(self.Objects[id].Model)
		self.dt.CurObject:Spawn()
		self.dt.CurObject:Activate()
		self.dt.CurObject:SetPos(self:LocalToWorld(Vector(0,0,Vector(0,0,self.dt.CurObject:OBBMins().z):Distance(Vector(0,0,self.dt.CurObject:GetPos().z))+10)))
		self.dt.CurObject:SetParent(self)
		self.dt.CurObject.dt.Factory = self
	else
		print("Invalid ID "..tostring(id))
	end
end

function ENT:OnRestore()
	WTib.Restored(self)
end

concommand.Add("wtib_factory_closemenu",function(ply,com,args)
	local ent = ents.GetByIndex(args[1])
	if ValidEntity(ent) then
		ent.BeingUsed = false
		ent.PlayerUsingMe = nil
	end
end)

concommand.Add("wtib_factory_buildobject",function(ply,com,args)
	local ent = ents.GetByIndex(args[1])
	if ValidEntity(ent) then
		ent:BuildObject(math.Round(args[2]))
	end
end)
