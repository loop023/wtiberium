AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextTiberiumAdd = 0
ENT.TiberiumAmount = 0
ENT.NextProduce = 0
ENT.Accelerate = false
ENT.AccReturn = true
ENT.Produces = {}
ENT.NextGas = 0

function ENT:Initialize()
	self:SetModel("models/props_gammarays/tiberium.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetMaterial("models/debug/debugwhite")
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
	self.NextProduce = CurTime()+math.Rand(30,60)
	self.NextGas = CurTime()+math.Rand(5,60)
	self:Think()
	self:SetTiberiumAmount(math.Rand(200,500))
	self:SetColor(self.r,self.g,self.b,self:GetTiberiumAmount()/(self:GetNWInt("CDevider") or 16)+5)
end

function ENT:CreateCDevider()
	for i=2,100 do
		if (self.MaxTiberium/i) == 250 then
			self:SetNWInt("CDevider",i)
			return i
		end
	end
end

function ENT:SetFieldReprodce(ent)
	self.OverrideShouldReproduce = true
	self.Produce = ent
end

function ENT:Think()
	if !self.WTib_Field then self.WTib_Field = WTib_CreateNewField(self) end
	if !self:GetNWInt("CDevider") or self:GetNWInt("CDevider") == 0 or self:GetNWInt("CDevider") == "" then self:CreateCDevider() end
	self.a = self:GetTiberiumAmount()/(self:GetNWInt("CDevider") or 16)+5
	if self.NextTiberiumAdd <= CurTime() and self.TiberiumAdd then
		self:AddTiberiumAmount(math.Rand(self.MinTiberiumGain,self.MaxTiberiumGain))
		self.NextTiberiumAdd = CurTime()+3
	end
	if self.NextGas <= CurTime() then
		self:EmitGas()
	end
	if self.OverrideShouldReproduce then
		if !self.Produce or !self.Produce:IsValid() then
			self.OverrideShouldReproduce = false
		end
	end
	if self.NextProduce <= CurTime() and self:GetTiberiumAmount() >= (self.MinReprodutionTibRequired or self.MaxTiberium-700) then
		self:Reproduce()
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

function ENT:SetGrowthAccelerate(a)
	self.Accelerate = tobool(a)
	if !self.Accelerate and !self.AccReturn then
		self.NextProduce = self.NextProduce+20
		self.AccReturn = true
	end
end

function ENT:SetTargetColor(r,g,b,a)
	self.Tr = math.Clamp(r,0,255)
	self.Tg = math.Clamp(g,0,255)
	self.Tb = math.Clamp(b,0,255)
	self.Ta = math.Clamp(a,0,255)
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
	if !self.Gas then return end
	pos = pos or self:GetPos()+Vector(math.Rand(-30,30),math.Rand(-30,30),math.Rand(30,50))
	local e = ents.Create("wtib_tiberiumgas")
	e:SetPos(pos)
	e:SetAngles(self:GetAngles())
	e.WDSE = self
	e.WDSO = self
	e:SetSize(50)
	e:SetStartColor(Color(self.r,self.g,self.b))
	e:SetEndColor(Color(self.r,self.g,self.b))
	e:Spawn()
	e:Activate()
	e:Fire("kill","",2)
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
	if self.OverrideShouldReproduce then return end
	if !self.ShouldReproduce then return end
	if WTib_MaxFieldSize > 0 and table.Count(self:GetFieldEnts()) >= WTib_MaxFieldSize-1 then return end
	if table.Count(self:GetAllProduces()) >= 3 then return end
	local a = 5
	if self.Accelerate then
		a = 10
	end
	for i=1,a do
		local fl = WTib_GetAllTiberium()
		table.Add(fl,player.GetAll())
		local t = util.QuickTrace(self:GetPos()+(self:GetUp()*60),VectorRand()*50000,fl)
		if t.Hit then
			local save = true
			for _,v in pairs(ents.FindByClass("wtib_sonicfieldemitter")) do
				if t.HitPos:Distance(v:GetPos()) < (v:GetNWInt("Radius") or 512) then
					save = false
					break
				end
			end
			for _,v in pairs(ents.FindInSphere(t.HitPos,500)) do
				if v.IsTiberium and v:GetClass() != self:GetClass() then
					save = false
					break
				end
			end
			for _,v in pairs(ents.FindInSphere(t.HitPos,150)) do
				if v.IsTiberium then
					save = false
					break
				end
			end
			local dist = t.HitPos:Distance(self:GetPos())
			if dist >= 150 and dist <= 700 and save then
				local e = self:SpawnFunction(self.WDSO,t)
				if e and e:IsValid() then
					local b = 0
					if self.Accelerate then
						b = 20
						self.AccReturn = false
					end
					self.NextProduce = CurTime()+math.Rand(math.Clamp((WTib_MinProductionRate or 30)-self.ReproductionRate,5,9998),math.Clamp((WTib_MaxProductionRate or 60)-self.ReproductionRate,6,9999))-b
					self:DrainTiberiumAmount(self.TiberiumDraimOnReproduction or self.MaxTiberium-200)
					WTib_AddToField(self.WTib_Field,e)
					e.WTib_Field = self.WTib_Field
					table.insert(self.Produces,e)
					return e
				else
					self.NextProduce = CurTime()+1
					return
				end
			end
		end
	end
	self.NextProduce = CurTime()+1
end
