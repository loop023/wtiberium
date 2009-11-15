AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local OffsetVector = Vector(40,20,-8)

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiberium_warhead_factory.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.NextRefine = 0
	self.CurWarhead = 1
	self.Inputs = WTib_CreateInputs(self,{"Create"})
	self.Outputs = WTib_CreateOutputs(self,{"Refined Tiberium","Energy","Tiberium Chemicals"})
	WTib_AddResource(self,"RefinedTiberium",0)
	WTib_AddResource(self,"TiberiumChemicals",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warheadfactory")
	e:SetPos(t.HitPos+t.HitNormal*39)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local En = WTib_GetResourceAmount(self,"energy")
	local RT = WTib_GetResourceAmount(self,"RefinedTiberium")
	local TC = WTib_GetResourceAmount(self,"TiberiumChemicals")
	self:SetNWString("Warhead",self.Warheads[self.CurWarhead].name or "N/A")
	self:SetNWString("energy",En)
	self:SetNWString("RefTib",RT)
	self:SetNWString("TibChem",TC)
	WTib_TriggerOutput(self,"Energy",En)
	WTib_TriggerOutput(self,"Refined Tiberium",RT)
	WTib_TriggerOutput(self,"Tiberium Chemicals",TC)
end

function ENT:TriggerInput(name,val)
	if name == "Create" then
		if val != 0 then
			self:CreateWarhead()
		end
	end
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	umsg.Start("WTib_OpenWarheadMenu",ply)
		umsg.Entity(self)
	umsg.End() 
end

function WTib_ReceiveWarhead(ply,com,args)
	for _,v in pairs(ents.FindByClass("wtib_warheadfactory")) do
		if tostring(v) == args[1] then
			v:SetWarhead(args[2])
			return
		end
	end
end
concommand.Add("wtib_setwarhead",WTib_ReceiveWarhead)

function WTib_ReceiveSpawnWarhead(ply,com,args)
	for _,v in pairs(ents.FindByClass("wtib_warheadfactory")) do
		if tostring(v) == args[1] then
			v:CreateWarhead(ply)
			return
		end
	end
end
concommand.Add("wtib_spawnwarhead",WTib_ReceiveSpawnWarhead)

function WTib_ReceiveCustomWarhead(ply,com,args)
	for _,v in pairs(ents.FindByClass("wtib_warheadfactory")) do
		if tostring(v) == args[1] then
			v:MakeCustomWarhead(args[2],args[3],args[4],ply)
			return
		end
	end
end
concommand.Add("wtib_spawncustomwarhead",WTib_ReceiveCustomWarhead)

function ENT:MakeCustomWarhead(En,RefTib,TibChem,ply)
	if WTib_GetResourceAmount(self,"energy") >= tonumber(En) and WTib_GetResourceAmount(self,"RefinedTiberium") >= tonumber(RefTib) and WTib_GetResourceAmount(self,"TiberiumChemicals") >= tonumber(TibChem) then
		WTib_ConsumeResource(self,"energy",tonumber(En))
		WTib_ConsumeResource(self,"RefinedTiberium",tonumber(RefTib))
		WTib_ConsumeResource(self,"TiberiumChemicals",tonumber(TibChem))
		local e = ents.Create("wtib_warhead_custom")
		e:SetPos(self:LocalToWorld(OffsetVector))
		e:SetAngles(self:GetAngles())
		e.WDSO = ply or self.WDSO or self
		e:SetValues(En,RefTib,TibChem)
		e:Spawn()
		e:Activate()
		self:EmitSound("buttons/button9.wav",100,100)
	else
		self:EmitSound("buttons/button10.wav",100,100)
	end
end

function ENT:SetWarhead(war)
	self.CurWarhead = math.Clamp(tonumber(war),1,table.Count(self.Warheads))
end

function ENT:CreateWarhead(ply)
	local EnergyR = self.Warheads[self.CurWarhead].EnergyRequired or 100
	local TiberiumR = self.Warheads[self.CurWarhead].RefinedTiberiumRequired or 200
	local TiberiumChemR = self.Warheads[self.CurWarhead].TiberiumChemicalsRequired or 0
	if WTib_GetResourceAmount(self,"RefinedTiberium") < TiberiumR or WTib_GetResourceAmount(self,"energy") < EnergyR or WTib_GetResourceAmount(self,"TiberiumChemicals") < TiberiumChemR then
		self:EmitSound("buttons/button10.wav",100,100)
		return false
	end
	WTib_ConsumeResource(self,"energy",EnergyR)
	WTib_ConsumeResource(self,"RefinedTiberium",TiberiumR)
	WTib_ConsumeResource(self,"TiberiumChemicals",TiberiumChemR)
	local e = ents.Create(self.Warheads[self.CurWarhead].Class)
	e:SetPos(self:LocalToWorld(self.Warheads[self.CurWarhead].Pos or Vector(65,0,-55)))
	e:SetAngles(self:GetAngles())
	e.WDSO = ply or self.WDSO or self
	e:Spawn()
	e:Activate()
	self:EmitSound("buttons/button9.wav",100,100)
	return e
end

WTib_ApplyFunctionsSV(ENT)
