
TOOL.Category		= "WTiberium"
TOOL.Name			= "#Sonic Plating"
TOOL.Command		= nil
TOOL.ConfigName		= nil

if CLIENT then
	language.Add("Tool_wtib_sonicplating_name","WTib sonic plating tool")
	language.Add("Tool_wtib_sonicplating_desc","Use this tool create sonic plating.")
	language.Add("Tool_wtib_sonicplating_0","Left click to replace a prop as a sonic plate\nRight click to create a sonic plate")
	language.Add("Undone_wtib_sonicplating","Undone WTib sonic plate")
	language.Add("Cleaned_wtib_sonicplating","Cleaned up all WTib sonic plates")
	language.Add("SBoxLimit_wtib_sonicplating","You've reached the WTib sonic plates limit!")
end

function TOOL:LeftClick(t,noweld)
	if !t.Hit or !self:GetOwner():CheckLimit("wtib_sonicplating") then return false end
	local ent = t.Entity
	if !ent or !ent:IsValid() then return false end
	if !SERVER then return true end
	if !util.IsValidPhysicsObject(t.Entity,t.PhysicsBone) then return false end
	local e = ents.Create("wtib_sonicplating")
	e:SetPos(ent:GetPos())
	e:SetAngles(ent:GetAngles())
	e.WDSO = ent.WDSO or self:GetOwner()
	if ent.ZatMode == 1 then -- Zat compatability
		e.ZatMode = 2
		e.LastZat = ent.LastZat or CurTime()
	end
	e:SetModel(ent:GetModel())
	e:SetSkin(ent:GetSkin())
	e:SetColor(ent:GetColor())
	e:SetMaterial(ent:GetMaterial())
	e:SetCollisionGroup(ent:GetCollisionGroup())
	e:Spawn()
	e:Activate()
	self:GetOwner():AddCount("wtib_sonicplating",e)
	undo.Create("wtib_sonicplating")
		for _,v in pairs(constraint.FindConstraints(ent,"NoCollide")) do
			local a
			if v.Ent1 == ent then a = v.Ent2 else a = v.Ent1 end
			constraint.NoCollide(e,a,v.Bone1,v.Bone2)
		end
		for _,v in pairs(constraint.FindConstraints(ent,"Weld")) do
			local a
			if v.Ent1 == ent then a = v.Ent2 else a = v.Ent1 end
			constraint.Weld(e,a,v.Bone1,v.Bone2,v.forcelimit,v.nocollide)
		end
		undo.AddEntity(e)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	ent:Remove()
	return true
end

function TOOL:RightClick(t)
	local e = ents.Create("wtib_sonicplating")
	e:SetModel("models/props_lab/blastdoor001c.mdl")
	e:SetPos(t.HitPos)
	e.WDSO = self:GetOwner()
	e:Spawn()
	e:Activate()
	self:GetOwner():AddCount("wtib_sonicplating",e)
	undo.Create("wtib_sonicplating")
		undo.AddEntity(e)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	return true
end

function TOOL:Reload(t)
	return false
end

function TOOL:Think()
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header",{Text = "#Tool_wtib_sonicplating_name",Description = "#Tool_wtib_sonicplating_desc"})
end
