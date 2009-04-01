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

function ENT:Explode(ent,data)
	for _,v in pairs(ents.FindInSphere(data.HitPos,500) do
		if v:IsNPC() or v:IsPlayer() then
			-- Something will come in here.
		else
			local e = ents.Create("wtib_tiberiumprop")
			e:SetPos(v:GetPos())
			e:SetModel(v:GetModel())
			e:SetAngles(v:GetAngles())
			e:SetColor(v:GetColor())
			e:SetSkin(v:GetSkin())
			if v.ZatMode == 1 then -- Zat compatability
				e.ZatMode = 2
				e.LastZat = CurTime()
			end
			e:Spawn()
			e:Activate()
			v:Remove()
		end
	end
	ent:Remove()
end
