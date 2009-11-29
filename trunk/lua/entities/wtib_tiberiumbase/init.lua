AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextTiberiumAdd = 0
ENT.LastAccelerate = 0
ENT.TiberiumAmount = 0
ENT.NextProduce = 0
ENT.Produces = {}
ENT.NextGas = 0

function ENT:Initialize()
	self:SetModel("models/props_gammarays/tiberium.mdl")
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
	return WTib_CreateTiberiumByTrace(t,self.Class,p)
end

function ENT:SecInit()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.NextProduce = CurTime()+math.Rand(30,60)
	self.NextGas = CurTime()+math.Rand(5,60)
	self:Think()
	self:SetTiberiumAmount(math.Rand(200,500))
	self:SetColor(self.r,self.g,self.b,10)
	self:SetTargetColor(self.r,self.g,self.b,self:GetTiberiumAmount()/(self:GetNWInt("CDevider") or 16)+5)
end

function ENT:CreateCDevider()
	for i=2,100 do
		if (self.MaxTiberium/i) == 250 then
			self:SetNWInt("CDevider",i)
			return i
		end
	end
end

function ENT:SetField(a)
	self.WTib_Field = a
end

function ENT:GetField()
	return self.WTib_Field
end

function ENT:Think()
	if !self.WTib_Field then self:SetField(WTib_CreateNewField(self)) end
	if !self:GetNWInt("CDevider") or self:GetNWInt("CDevider") == 0 or self:GetNWInt("CDevider") == "" then self:CreateCDevider() end
	self.a = self:GetTiberiumAmount()/(self:GetNWInt("CDevider") or 16)+5
	if self.NextTiberiumAdd <= CurTime() and self.TiberiumAdd then
		self:AddTiberiumAmount(math.Rand(self.MinTiberiumGain,self.MaxTiberiumGain))
		self.NextTiberiumAdd = CurTime()+3
	end
	if self.NextGas <= CurTime() then
		self:EmitGas()
	end
	if self.NextProduce <= CurTime() and self:GetTiberiumAmount() >= (self.MinReprodutionTibRequired or self.MaxTiberium-700) then
		local e = self:Reproduce()
		if e then
			self.NextProduce = CurTime()+(self.ReproduceDelay or (self:IsAccelerated() and self.ReproduceDelay/2))
			WTib_AddToField(self:GetField(),e)
			e:SetField(self:GetField())
			table.insert(self.Produces,e)
		end
	end
	if self.SecThink then self:SecThink() end
	self:CheckColor()
	self:NextThink(CurTime()+1)
	return true
end

function ENT:SetTiberiumAmount(am)
	self:SetNWInt("TiberiumAmount",math.Clamp(am,-10,self.MaxTiberium))
	self:SetTargetColor(self.r,self.g,self.b,math.Clamp(self.a,30,255))
	if self:GetNWInt("TiberiumAmount") <= 0 then
		self:Die()
	end
end

function ENT:AddTiberiumAmount(am)
	self:SetTiberiumAmount(math.Clamp(self:GetTiberiumAmount()+am,-10,self.MaxTiberium))
end

function ENT:DrainTiberiumAmount(am)
	self:SetTiberiumAmount(math.Clamp(self:GetTiberiumAmount()-am,-10,self.MaxTiberium))
end

function ENT:GetTiberiumAmount()
	return self:GetNWInt("TiberiumAmount")
end

function ENT:SetTargetColor(r,g,b,a)
	self.Tr = math.Clamp(r,0,255)
	self.Tg = math.Clamp(g,0,255)
	self.Tb = math.Clamp(b,0,255)
	self.Ta = math.Clamp(a,0,250)
end

function ENT:CheckColor()
	local inc = 2
	local Or,Og,Ob,Oa = self:GetColor()
	self:SetColor(math.Approach(Or,self.Tr,inc),math.Approach(Og,self.Tg,inc),math.Approach(Ob,self.Tb,inc),math.Approach(Oa,self.Ta,inc))
end

function ENT:Die()
	for i=1,3 do
		self:EmitGas()
	end
	self:Remove()
end

function ENT:EmitGas(pos)
	if !self.Gas or !WTib_ProduceGas then return end
	pos = pos or self:GetPos()+Vector(math.Rand(-30,30),math.Rand(-30,30),math.Rand(30,50))
	local e = ents.Create("wtib_tiberiumgas")
	e:SetPos(pos)
	e:SetAngles(self:GetAngles())
	e:SetTiberium(self)
	e:Spawn()
	e:Activate()
	self.NextGas = CurTime()+math.Rand(5,60)
end

function ENT:OnTakeDamage(di)
	self:EmitGas(di:GetDamagePosition())
	if di:IsDamageType(DMG_BURN) and !self.IgnoreExpBurDamage then
		self:AddTiberiumAmount(math.Clamp(di:GetDamage()*math.Rand(0.8,2),2,self.MaxTiberium))
		self.NextProduce = 0
		self.NextTiberiumAdd = 0
		return
	end
	if self.NextProduce-CurTime() < 60 then
		self.NextProduce = CurTime()+(self.ReproduceDelay or 60)
	end
	self.NextTiberiumAdd = CurTime()+10
	self:DrainTiberiumAmount(di:GetDamage()/1.5)
end

function ENT:OnRemove()
	for i=1,3 do
		self:EmitGas()
	end
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
	self.NextTiberiumAdd = CurTime()+(10+am/5)
	if self.NextProduce-CurTime() < 60 then
		self.NextProduce = CurTime()+(self.ReproduceDelay or 60)
	end
	self:DrainTiberiumAmount(am)
	self:EmitGas()
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
	local pos = self:GetPos()+(self:GetUp()*70)
	for i=1,self:GetReproduceLoops() do
		WTib_Print("\tLoop "..i)
		local t = WTib_Trace(pos,VectorRand()*math.random(-800,800),fl)
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
						elseif Dist <= 500 then
							if v:GetClass() != self:GetClass() then
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
				local e = self:SpawnFunction(self.WDSO,t)
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

function ENT:Accelerate(time)
	self.LastAccelerate = time
end

function ENT:GetReproduceLoops()
	return 5 or (self:IsAccelerated() and 10)
end

function ENT:IsAccelerated()
	return self.LastAccelerate > CurTime()
end

function ENT:GetMinProductionRate()
	return WTib_MinRedProductionRate or 30
end

function ENT:GetMaxProductionRate()
	return WTib_MaxRedProductionRate or 60
end
