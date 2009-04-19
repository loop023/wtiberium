
function EFFECT:Init(data)
	self.Start = data:GetOrigin()
	self.Ang = data:GetAngles()
	self.WDSO = data:GetEntity()
	local aim = self.Start
	self.Ang.z = 0
	local time = 0
	self.Start = self.Start+self.Ang*10
	for i = 1,data:GetScale() do
		self.Start = self.Start+self.Ang*90
		time = time+0.1
		timer.Simple(time,spike,self.Start,self)
	end
	self.Time = CurTime()+time
end

function EFFECT:Think()
	return (self.Time < CurTime())
end

function EFFECT:Render()
end

function EFFECT:Spike(pos)
	local tab = {}
	local ed = EffectData()
	ed:SetOrigin(pos)
	ed:SetMagnitude(80)
	ed:SetScale(10)
	ed:SetRadius(30)
	util.Effect("AR2Explosion",effectdata)
	for k,v in pairs(ents.FindInSphere(self:GetPos(),50) do
		if v.IsTiberium then
			tab[k] = v.IgnoreExpBurDamage
			v.IgnoreExpBurDamage = true
		end
	end
	util.BlastDamage(self.WDSO,self.WDSO,pos,30,25)
	for k,v in pairs(ents.FindInSphere(self:GetPos(),50) do
		if v.IsTiberium and tab[k] != nil then
			v.IgnoreExpBurDamage = tab[k]
		end
	end
end
