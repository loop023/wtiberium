AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/grenadeAmmo.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	timer.Simple(5,function() if self and self:IsValid() then self:Explode() end end)
	local e = ents.Create("ai_sound")
	e:SetPos(self:GetPos())
	e:SetParent(self)
	e:SetKeyValue("soundtype","8")
	e:SetKeyValue("volume","250")
	e:SetKeyValue("duration","5")
	e:Spawn()
	e:Activate()
	e:Fire("EmitAISound","","")
end

function ENT:Explode()
	local fl = {}
	local pos = self:GetPos()
	for i=1,10 do
		timer.Simple(i/3.3,function()
			for _,v in pairs(ents.FindInSphere(pos,i*19)) do
				if v.IsTiberium and !table.HasValue(fl,v) then
					v:DrainTiberiumAmount(math.Rand(500,1500))
				end
			end
		end)
	end
	self:EmitSound("wtiberium/sonicexplosion/explode.wav",100,255)
	local ed = EffectData()
	ed:SetOrigin(pos)
	ed:SetStart(pos)
	ed:SetScale(3)
	util.Effect("SonicExplosion",ed)
	self:Remove()
end
