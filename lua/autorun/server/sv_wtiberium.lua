
WTib = WTib or {}
WTib.Config						= {}
WTib.Config.MaximumFieldSize	= 50

function WTib.CreateTiberium(creator,class,t,ply)
	local Call = hook.Call("WTib_TiberiumCanGrow",GAMEMODE,class,t,creator)
	if Call != nil and !tobool(a) then return end
	if !t.Hit or (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then return end
	local e = ents.Create(class)
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	if creator and creator.IsValid and creator:IsValid() then
		e:SetField(creator:GetField())
	end
	e.WDSO = p
	e:Spawn()
	e:Activate()
	if ValidEntity(t.Entity) and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	return e
end

/*
	Misc hooks
*/

function WTib.TiberiumCanGrow(class,t,ent)
	// TODO: Prevent fields from extending from their max size here.
	for _,v in pairs(ents.FindInSphere(t.HitPos,600)) do
		local Dist = v:GetPos():Distance(t.HitPos)
		if v.IsTiberium then
			if v:GetClass() == class then
				if Dist <= 80 then
					return false
				end
			elseif Dist <= 500 then
				return false
			end
		end
	end
end
hook.Add("WTib_TiberiumCanGrow","WTib.TiberiumCanGrow",WTib.TiberiumCanGrow)

function WTib.WDSDamagePrevention(ent,dmg)
	if ent.IsTiberium then
		return false
	end
end
hook.Add("WDS_EntityTakeDamage","WTib.WDSDamagePrevention",WTib.WDSDamagePrevention)

/*
	Field management
*/

WTib.Fields	= {}

function WTib.CreateField(master,fmax)
	local Field = {
		Master = master,
		MaximumEntities = fmax or WTib.Config.MaximumFieldSize,
		Entities = {master}
	}
	for k,v in pairs(WTib.Fields) do
		if !WTib.Fields[k] then
			WTib.Fields[k] = Field
			return k
		end
	end
	local Num = table.Count(WTib.Fields)+1
	WTib.Fields[Num] = Field
	return Num
end

function WTib.KillField(num)
	WTib.Fields[num] = nil
end

function WTib.GetFieldCount(num)
	return table.Count(WTib.Fields[num].Entities)
end

function WTib.GetFieldMax(num)
	return WTib.Fields[num].MaximumEntities or WTib.Config.MaximumFieldSize
end

function WTib.IsValidField(num)
	return WTib.Fields[num] != nil and type(WTib.Fields[num]) == "table"
end

timer.Create("WTib.FieldTimer",5,0,function()
	for k,v in pairs(WTib.Fields) do
		if !ValidEntity(v.Master) then
			local Ent
			local LIndex = 10000
			for _,e in pairs(v.Entities) do
				if e:EntIndex() <= LIndex then
					Ent = e
				end
			end
			v.Master = Ent
			if !ValidEntity(Ent) then
				WTib.KillField(k)
			end
		end
	end
end)

local Tags = GetConVarString("sv_tags") //Thanks PHX!
if Tags == nil then
	RunConsoleCommand("sv_tags","WTiberium")
elseif !string.find(Tags,"WTiberium") then
	RunConsoleCommand("sv_tags","WTiberium,"..Tags)
end
