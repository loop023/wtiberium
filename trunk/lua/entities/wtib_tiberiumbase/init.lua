AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextTiberiumAdd = 0
ENT.TiberiumAmount = 0
ENT.NextProduce = 0
ENT.Produces = {}
ENT.NextGas = 0

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
	if !t.Hit then return end
	local e = ents.Create("wtib_tiberiumbase")
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	for i=1,3 do
		e:EmitGas()
	end
	return e
end

function ENT:CreateCDevider()
	local CDiv = 2
	for i=2,100 do
		if (self.MaxTiberium/i) == 250 then
			self.Divider = i
			return i
		end
		CDiv = CDiv+1
	end
end

function ENT:Think()
	if !self.Divider then self:CreateCDevider() end
	self.a = self:GetTiberiumAmount()/(self.Divider or 16)+5
	if self.NextTiberiumAdd <= CurTime() and self.TiberiumAdd then
		self:AddTiberiumAmount(math.random(self.MinTiberiumGain,self.MaxTiberiumGain))
		self.NextTiberiumAdd = CurTime()+3
	end
	if self.NextGas <= CurTime() and self.Gas then
		self:EmitGas()
	end
	if self.NextProduce <= CurTime() and self:GetTiberiumAmount() >= (self.MinReprodutionTibRequired or self.MaxTiberium-700) and self.ShouldReproduce then
		self:Reproduce()
	end
	if self.SecThink then self:SecThink() end
	self:NextThink(CurTime()+1)
	return true
end

function ENT:SetTiberiumAmount(am)
	self:SetNWInt("TiberiumAmount",math.Clamp(am,-10,self.MaxTiberium))
	self:SetColor(self.r,self.g,self.b,math.Clamp(self.a,30,255))
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

function ENT:Die()
	for i=1,3 do
		self:EmitGas()
	end
	self:Remove()
end

function ENT:EmitGas(pos)
	local e = ents.Create("wtib_tiberiumgas")
	e:SetPos(pos or self:GetPos()+Vector(math.random(-30,30),math.random(-30,30),math.random(30,50)))
	e:SetAngles(self:GetAngles())
	e.WDSE = self
	e.WDSO = self.WDSO or self
	e:SetSize(50)
	e:SetStartColor(Color(self.r,self.g,self.b))
	e:SetStartColor(Color(self.r,self.g,self.b))
	e:Spawn()
	e:Activate()
	e:Fire("kill","",2)
	self.NextGas = CurTime()+math.random(5,60)
end

function ENT:OnTakeDamage(di)
	self:EmitGas(di:GetDamagePosition())
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

function ENT:Reproduce()
	if (WTib_MaxTotalTiberium or 0) > 0 and WTib_TiberiumEntitiesCount >= WTib_MaxTotalTiberium then return false end
	local a = {}
	for _,v in pairs(self.Produces) do
		if v and v:IsValid() then
			table.insert(a,v)
		end
	end
	self.Produces = a
	if table.Count(self.Produces) >= (WTib_MaxProductionAmount or 3) then return end
	for i=1,5 do
		local fl = WTib_GetAllTiberium()
		table.Add(fl,player.GetAll())
		local t = util.QuickTrace(self:GetPos()+Vector(0,0,60),VectorRand()*50000,fl)
		if t.Hit then
			local save = true
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
				self.NextProduce = CurTime()+math.random(WTib_MinProductionRate or 30,WTib_MaxProductionRate or 60)
				self:DrainTiberiumAmount(self.TiberiumDraimOnReproduction or self.MaxTiberium-200)
				local e = self:SpawnFunction(self.WDSO,t)
				table.insert(self.Produces,e)
				return e
			end
		end
	end
	WTib_TiberiumEntitiesCount = WTib_TiberiumEntitiesCount+1
	self.NextProduce = CurTime()+1
end
