AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_thermonium")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Explode(missile,data)
	for _,v in pairs(ents.FindInSphere(data.HitPos,700)) do
		if v:IsNPC() or v:IsPlayer() then
			-- Something will come in here.
		elseif v != missile and v != missile.FTrail and v:IsValid() and !v:IsWeapon() and !v:IsWorld() and v:GetPhysicsObject():IsValid() and string.find(v:GetClass(), "func_") != 1 and v:GetClass() != "physgun_beam" then
			print(v:GetClass())
			local e = ents.Create("wtib_tiberiumprop")
			e:SetPos(v:GetPos())
			e:SetModel(v:GetModel())
			e:SetMaterial(v:GetMaterial())
			e:SetAngles(v:GetAngles())
			e:SetColor(Color(0,200,20,230))
			e:SetSkin(v:GetSkin())
			e:SetCollisionGroup(v:GetCollisionGroup())
			e.Class = e:GetClass()
			if v.ZatMode == 1 then -- Zat compatability
				e.ZatMode = 2
				e.LastZat = v.LastZat or CurTime()
			end
			e:Spawn()
			e:Activate()
			v:Remove()
		end
	end
	missile:Remove()
end
