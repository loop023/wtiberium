AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextProduce = 0
ENT.Produces = {}

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

function ENT:SecInit()
	self:SetColor(self.r,self.g,self.b,150)
	self:SetMaterial("models/debug/debugwhite")
	self.NextProduce = CurTime()+self.ReproduceDelay
	self:Think()
end

function ENT:SpawnFunction(p,t)
	return WTib_CreateTiberiumByTrace(t,self.Class,p)
end

function ENT:Think()
	if !self.WTib_Field then self:SetField(WTib_CreateNewField(self)) end
	if self.NextProduce <= CurTime() then
		local e = self:Reproduce()
		if e then
			self.NextProduce = CurTime()+(self.ReproduceDelay or (self:IsAccelerated() and self.ReproduceDelay/2))
			WTib_AddToField(self:GetField(),e)
			e:SetField(self:GetField())
			table.insert(self.Produces,e)
		end
	end
	if self.SecThink then self:SecThink() end
	self:NextThink(CurTime()+1)
	return true
end

function ENT:SetField(a)
	self.WTib_Field = a
end

function ENT:GetField()
	return self.WTib_Field
end

function ENT:Touch(ent)
	WTib_InfectLiving(ent,self)
	ent:TakeDamage(math.Rand(60,120),self,self)
end

function ENT:SetTiberiumAmount(am)
	-- Since i dont want to break the ent.IsTiberium check ill leave this blank.
	return false
end

function ENT:AddTiberiumAmount(am)
	-- Since i dont want to break the ent.IsTiberium check ill leave this blank.
	return false
end

function ENT:DrainTiberiumAmount(am)
	-- Since i dont want to break the ent.IsTiberium check ill leave this blank.
	return false
end

function ENT:GetTiberiumAmount()
	-- Since i dont want to break the ent.IsTiberium check ill leave this blank.
	return 10
end

function ENT:OnTakeDamage(di)
end

function ENT:GetFieldEnts()
	return WTib_GetFieldEnts(self.WTib_Field) or {}
end

function ENT:GetAllProduces()
	local a = {}
	for _,v in pairs(self.Produces) do
		if v and v:IsValid() then
			table.insert(a,v)
		end
	end
	self.Produces = a
	return a
end

function ENT:TakeSonicDamage(am)
	am = am or math.Rand(10,100)
	self.NextProduce = self.NextProduce+(10+am/7)
end

function ENT:Reproduce()
	if WTib_GetFieldCount(self:GetField())+1 > WTib_GetMaxFieldMembers(self:GetField()) then WTib_Print("Max Field : "..WTib_GetFieldCount(self:GetField()).." out of "..WTib_GetMaxFieldMembers(self:GetField())) return end
	WTib_Print("Check passed 1")
	local AllEnts = ents.GetAll()
	local fl = {}
	for _,v in pairs(AllEnts) do
		if v.IsTiberium or (v.Alive and v:Alive()) then
			table.insert(fl,v)
		end
	end
	local pos = self:GetPos()+(self:GetUp()*100)
	local Class = self.TiberiumClass or "wtib_tiberiumbase"
	for i=1,self:GetReproduceLoops() do
		WTib_Print("\tLoop "..i)
		local t = WTib_Trace(pos,VectorRand()*math.random(-1000,1000),fl)
		WTib_Print("\tHitPos : "..tostring(t.HitPos))
		if t.Hit then
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
			if WTib_Debug then
				util.Effect("WTib_DebugTrace",ed)
			end
			WTib_Print("\t\tHit!")
			local Save = true
			for _,v in pairs(AllEnts) do
				if !v:IsWorld() then
					local Dist = t.HitPos:Distance(v:GetPos())
					if v:GetClass() == "wtib_sonicfieldemitter" and Dist < (v:GetNWInt("Radius") or 512) then
						WTib_Print("\t\t\tSonic emitter")
						Save = false
						break
					elseif t.HitSky then
						WTib_Print("\t\t\tWe hit the sky")
						Save = false
						break
					elseif v.IsTiberium then
						WTib_Print("\t\t\tTiberium close!")
						if Dist <= 150 then
							WTib_Print("\t\t\tWay to close!")
							Save = false
							break
						elseif Dist <= 450 then
							if v:GetClass() != Class and v:GetClass() != self:GetClass() then
								WTib_Print("\t\t\tNot own class!")
								Save = false
								break
							end
						end
					end
				end
			end
			if Save then
				WTib_Print("\t\tSave, creating ent..")
				local e = WTib_CreateTiberiumByTrace(t,Class,self.WDSO)
				if e and e:IsValid() then
					WTib_Print("\t\tValid ent returned!")
					return e
				end
			end
		else
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
				ed:SetScale(2)
			if WTib_Debug then
				util.Effect("WTib_DebugTrace",ed)
			end
		end
	end
end

function ENT:GetReproduceLoops()
	return 7 or (self:IsAccelerated() and 12)
end

function ENT:IsAccelerated()
	return self.LastAccelerate > CurTime()
end
