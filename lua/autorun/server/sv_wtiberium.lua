
WTib = WTib or {}
WTib.Config						= {}
WTib.Config.MaximumFieldSize	= 70

/*
	Console Commands
*/

concommand.Add("wtib_removealltiberium",function(ply,com,args)
	if ply:IsAdmin() then
		for _,v in pairs(WTib.GetAllTiberium()) do
			v:Remove()
		end
		for _,v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				v:ChatPrint("All Tiberium has been removed by \""..ply:Nick().."\".")
			else
				v:ChatPrint("All Tiberium has been removed.")
			end
		end
	else
		ply:ChatPrint("This command is admin only.")
	end
end)

/*
	Misc stuff
*/

function WTib.GetAllTiberium(tFilter)
	tFilter = tFilter or {}
	local tData = {}
	for _,v in pairs(ents.GetAll()) do
		if !table.HasValue(tFilter,v) and v.IsTiberium then
			table.insert(tData,v)
		end
	end
	return tData
end

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
	util.Decal(e.Decal,t.HitPos-(t.HitNormal*(e.DecalSize or 1)),t.HitPos+(t.HitNormal*(e.DecalSize or 1)))
	if ValidEntity(t.Entity) and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	return e
end

local Tags = GetConVarString("sv_tags") //Thanks PHX!
if Tags == nil then
	RunConsoleCommand("sv_tags","WTiberium")
elseif !string.find(Tags,"WTiberium") then
	RunConsoleCommand("sv_tags","WTiberium,"..Tags)
end

function WTib.SpawnFunction(p,t,offset,ent)
	if !t.Hit then return end
	offset = offset or 1
	local e = ents.Create(WTib.GetClass(ent))
	e:SetPos(t.HitPos+t.HitNormal*offset)
	e.WDSO = p
	e:Spawn()
	e:Activate()
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

/*
	Field management
*/

WTib.Fields	= {}

function WTib.CreateField(master,fmax)
	local Field = {
		Master = master,
		MaximumEntities = fmax or WTib.Config.MaximumFieldSize,
		Entities = {master},
		MostDistant = master
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

function WTib.GetFurthestCrystalFromField(num)
	return WTib.Fields[num].MostDistant
end

function WTib.AddFieldMember(num,ent)
	if WTib.IsValidField(num) then
		table.insert(WTib.Fields[num].Entities,ent)
		local Ent
		local Dis = 0
		for _,v in pairs(WTib.Fields[num].Entities) do
			local a = v:GetPos():Distance(WTib.GetFieldMaster(num):GetPos())
			if a > Dis then
				Ent = v
				Dis = a
			end
		end
		WTib.Fields[num].MostDistant = Ent
	end
end

function WTib.GetFieldCount(num)
	return table.Count(WTib.Fields[num].Entities)
end

function WTib.IsFieldFull(num)
	return WTib.GetFieldCount(num) >= WTib.GetFieldMax(num)
end

function WTib.GetFieldMaster(num)
	if !ValidEntity(WTib.Fields[num].Master) then
		WTib.SelectNewFieldMaster(num)
	end
	return WTib.Fields[num].Master
end

function WTib.GetFieldMax(num)
	return WTib.Fields[num].MaximumEntities or WTib.Config.MaximumFieldSize
end

function WTib.IsValidField(num)
	return WTib.Fields[num] != nil and type(WTib.Fields[num]) == "table"
end

function WTib.SelectNewFieldMaster(num)
	local Ent
	local LIndex = 10000
	for _,e in pairs(WTib.Fields[num].Entities) do
		if e:EntIndex() <= LIndex then
			Ent = e
		end
	end
	WTib.Fields[num].Master = Ent
	if !ValidEntity(Ent) then
		WTib.KillField(num)
	end
end

timer.Create("WTib.FieldTimer",5,0,function()
	for num,field in pairs(WTib.Fields) do
		for k,v in pairs(field.Entities) do
			if !ValidEntity(v) then
				WTib.Fields[num].Entities[k] = nil
			end
		end
	end
end)
