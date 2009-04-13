AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(20,220,20,255)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_warhead_seeder")
	e:SetPos(t.HitPos+t.HitNormal*60)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Explode(missile,data)
	print("Exploding")
	data = data or {}
	print("Printing data :")
	PrintTable(data)
	print("Data printed, effect starting")
	local ed = EffectData()
	ed:SetOrigin(data.HitPos or missile:GetPos())
	ed:SetStart(data.HitPos or missile:GetPos())
	util.Effect("SeederExplosion",ed)
	print("Effect Created")
	local t = util.QuickTrace(missile:GetPos(),data.HitPos or missile:GetForward()*80,{missile,missile.FTrail})
	print("Printing trace results")
	PrintTable(t)
	if (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then missile:Remove() return end
	print("Check passed")
	print("Creating ent")
	local e = ents.Create("wtib_greentiberium")
	print("Ent created")
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	print("Angle : "..tostring(ang))
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	print("New angle : "..tostring(ang))
	e:SetAngles(ang)
	print("Angles set")
	e:SetPos(t.HitPos)
	print("Pos set")
	e.WDSO = missile.WDSO
	print("WDSO set")
	e:Spawn()
	print("Spawned")
	e:Activate()
	print("Activated")
	if t.Entity and !t.Entity:IsWorld() then
		print("Hit entity, setting movetype")
		e:SetMoveType(MOVETYPE_VPHYSICS)
		print("Movetype set, setting parent")
		e:SetParent(t.Entity)
		print("Parent sec")
	end
	print("Emitting gas")
	for i=1,3 do
		print(i)
		e:EmitGas()
	end
	print("Producing")
	for i=1,6 do
		print(i)
		e:SetTiberiumAmount(3000)
		e:Reproduce()
	end
	print("Setting tiberium amount")
	e:SetTiberiumAmount(math.Rand(200,500))
	print("Removing missile")
	missile:Remove()
end

function ENT:OnWarheadConnect(missile)
	missile:SetColor(20,220,20,255)
	return true
end
