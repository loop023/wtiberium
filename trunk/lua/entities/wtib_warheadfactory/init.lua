AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_wasteland/laundry_dryer002.mdl")
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
	e:SetPos(t.HitPos+t.HitNormal*54)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWString("Warhead",self.Warheads[self.CurWarhead].name or "N/A")
	WTib_TriggerOutput(self,"Energy",WTib_GetResourceAmount(self,"energy"))
	WTib_TriggerOutput(self,"Refined Tiberium",WTib_GetResourceAmount(self,"RefinedTiberium"))
	WTib_TriggerOutput(self,"Tiberium Chemicals",WTib_GetResourceAmount(self,"TiberiumChemicals"))
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
	print("Received the command.")
	for _,v in pairs(ents.FindByClass("wtib_warheadfactory")) do
		if tostring(v) == args[1] then
			print("Found the factory! : "..args[1].." set to "..args[2].."!")
			v:SetWarhead(args[2])
			return
		end
	end
	print("Factory "..tostring(args[1]).." not found!")
end
concommand.Add("wtib_setwarhead",WTib_ReceiveWarhead)

function ENT:SetWarhead(war)
	self.CurWarhead = math.Clamp(tonumber(war),1,table.Count(self.Warheads))
end

function ENT:CreateWarhead()
	local EnergyR = self.Warheads[self.CurWarhead].EnergyRequired or 100
	local TiberiumR = self.Warheads[self.CurWarhead].RefinedTiberiumRequired or 200
	local TiberiumChemR = self.Warheads[self.CurWarhead].TiberiumChemicalsRequired or 0
	if WTib_GetResourceAmount(self,"RefinedTiberium") < TiberiumR or WTib_GetResourceAmount(self,"energy") < EnergyR or WTib_GetResourceAmount(self,"TiberiumChemicals") < TiberiumChemR then
		self:EmitSound("buttons/button10.wav",100,100)
		return false
	end
	WTib_ConsumeResource(self,"energy",EnergyR)
	WTib_ConsumeResource(self,"Tiberium",TiberiumR)
	WTib_ConsumeResource(self,"TiberiumChemicals",TiberiumChemR)
	local e = ents.Create(self.Warheads[self.CurWarhead].Class)
	e:SetPos(self:LocalToWorld(self.Warheads[self.CurWarhead].Pos or Vector(65,0,-55)))
	e:SetAngles(self:GetAngles())
	e:Spawn()
	e:Activate()
	self:EmitSound("buttons/button9.wav",100,100)
	return e
end

function ENT:OnRemove()
	WTib_RemoveRDEnt(self)
	if (self.Outputs or self.Inputs) then
		WTib_Remove(self)
	end
end

function ENT:OnRestore()
	WTib_Restored(self)
end

function ENT:PreEntityCopy()
	WTib_BuildDupeInfo(self)
	if WireAddon then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
	WTib_ApplyDupeInfo(Ent,CreatedEntities)
	if WireAddon and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
	end
end
