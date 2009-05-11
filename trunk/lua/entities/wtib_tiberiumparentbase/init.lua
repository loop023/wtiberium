AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextProduce = 0
ENT.Produces = {}

function ENT:Initialize()
	self:SetModel("models/props_gammarays/tiberium.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(self.r,self.g,self.b,150)
	self:SetMaterial("models/debug/debugwhite")
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:SecInit()
end

function ENT:SecInit()
	self.NextProduce = CurTime()+self.ReproduceDelay
	self:Think()
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_tiberiumparentbase")
	e:SetPos(t.HitPos+t.HitNormal)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	if !self.WTib_Field then self.WTib_Field = WTib_CreateNewField(self) end
	if self.NextProduce <= CurTime() then
		self:Reproduce()
	end
	if self.SecThink then self:SecThink() end
	self:NextThink(CurTime()+1)
	return true
end

function ENT:Touch(ent)
	WTib_InfectLiving(ent)
	ent:TakeDamage(math.Rand(60,120),self.WDSO,self)
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

function ENT:SetTargetColor(r,g,b,a)
	self.Tr = math.Clamp(r,0,255)
	self.Tg = math.Clamp(g,0,255)
	self.Tb = math.Clamp(b,0,255)
	self.Ta = math.Clamp(a,0,255)
end

function ENT:CheckColor()
	local inc = 1
	local Or,Og,Ob,Oa = self:GetColor()
	print("Inc "..inc.." Cur : "..Or.." "..Og.." "..Ob.." "..Oa)
	self:SetColor(math.Approach(Or,self.Tr,inc),math.Approach(Og,self.Tg,inc),math.Approach(Ob,self.Tb,inc),math.Approach(Oa,self.Ta,inc))
end

function ENT:Die()
	self:Remove()
end

function ENT:OnTakeDamage(di)
	if di:IsDamageType(DMG_BURN) and !self.IgnoreExpBurDamage then
		self.NextProduce = 4
		self.NextTiberiumAdd = 0
		return
	end
	if self.NextProduce-CurTime() < 30 then
		self.NextProduce = CurTime()+(self.ReproduceDelay or 30)
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
	self.NextProduce = self.NextProduce+(10+am/7)
end

function ENT:Reproduce()
	if WTib_MaxFieldSize > 0 and table.Count(self:GetFieldEnts()) >= WTib_MaxFieldSize-1 then return end
	for i=1,7 do
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
				if v.IsTiberium and v:GetClass() != self.TiberiumClass then
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
				local e = WTib_CreateTiberiumByTrace(t,self.TiberiumClass or "wtib_tiberiumbase",self.WDSO)
				if e and e:IsValid() then
					self.NextProduce = CurTime()+math.Rand(self.ReproduceDelay-10,self.ReproduceDelay+10)
					WTib_AddToField(self.WTib_Field,e)
					e.WTib_Field = self.WTib_Field
					e:SetFieldReprodce(self)
					table.insert(self.Produces,e)
					return e
				else
					self.NextProduce = CurTime()+0.5
					return
				end
			end
		end
	end
	self.NextProduce = CurTime()+0.5
end
