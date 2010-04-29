ENT.Type			= "anim"
ENT.PrintName		= "Missile"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.WTib_IsMissile	= true

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Warhead")
end

function ENT:GetWarhead()
	return self.dt.Warhead
end

function ENT:GetWarheadTable(int)
	return self.Warheads[int or self.dt.Warhead]
end

ENT.Warheads =	{}
ENT.Warheads[1] =	{
						Name = "Basic",
						Explode = function(self,data)
							data = data or {}
							util.BlastDamage(self,self.WDSO,self:GetPos(),math.Rand(200,300),math.Rand(300,400))
							local ed = EffectData()
							ed:SetOrigin(data.HitPos or self:GetPos())
							ed:SetStart(data.HitPos or self:GetPos())
							ed:SetScale(3)
							util.Effect("Explosion",ed)
							self:Remove()
						end,
						Launch = function(self)
							local e = ents.Create("env_fire_trail")
							e:SetAngles(self:GetAngles())
							e:SetPos(self:LocalToWorld(Vector(-70,0,7)))
							e:SetParent(self)
							e:Spawn()
							e:Activate()
							self:DeleteOnRemove(e)
						end,
						Think = function(self)
							// Do nothing.
						end
					}