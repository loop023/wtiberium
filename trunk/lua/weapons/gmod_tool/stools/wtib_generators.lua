
TOOL.Category		= "WTiberium"
TOOL.Name			= "#Generators"
TOOL.Command		= nil
TOOL.ConfigName		= nil

local Items =	{
					"wtib_mediumgrowthaccelerator",
					"wtib_largeharvester",
					"wtib_mediumharvester",
					"wtib_smallharvester",
					"wtib_largetrip",
					"wtib_mediumtrip",
					"wtib_smalltrip",
					"wtib_tinytrip",
					"wtib_chemicalplant",
					"wtib_powerplant",
					"wtib_tibrefinery",
					"wtib_warheadfactory",
					"wtib_radar"
				}

TOOL.ClientConVar["nocollide"]	= "0"
TOOL.ClientConVar["class"]		= "1"

if CLIENT then
	language.Add("Tool_wtib_generators_name","WTib generators tool")
	language.Add("Tool_wtib_generators_desc","Use this tool to place WTib generators.")
	language.Add("Tool_wtib_generators_0","Left click to place the selected item\nRight click to place the selected item without welding")
	language.Add("Undone_wtib_generators","Undone WTib generator")
	language.Add("Cleaned_wtib_generators","Cleaned up all WTib generators")
	language.Add("SBoxLimit_wtib_generators","You've reached the WTib generator limit!")
end

function TOOL:LeftClick(t,noweld)
	if !t.Hit then return false end
	if !util.IsValidPhysicsObject(t.Entity,t.PhysicsBone) then return false end
	if !self:GetOwner():CheckLimit("wtib_generators") then return false end
	local cl = Items[tonumber(self:GetClientNumber("class"))]
	if !cl then return false end
	// Everything is checked, we can now make the entity.
	local e = scripted_ents.GetStored(cl).t:SpawnFunction(self:GetOwner(),t)
	if !e then return false end
	if !SERVER then return true end
	e.WDSO = self:GetOwner()
	local weld
	self:GetOwner():AddCount("wtib_generators",e)
	undo.Create("wtib_generators")
	if !noweld and e:GetPhysicsObject():IsValid() then
		undo.AddEntity(constraint.Weld(e,t.Entity,0,t.PhysicsBone,0))
		if !t.Entity:IsWorld() and tonumber(self:GetClientNumber("nocollide")) == 1 then
			undo.AddEntity(constraint.NoCollide(e,t.Entity,0,t.PhysicsBone))
		end
	end
	undo.AddEntity(e)
	undo.SetPlayer(self:GetOwner())
	undo.Finish()
	return true
end

function TOOL:RightClick(t)
	self:LeftClick(t,true)
	return true
end

function TOOL:Reload(t)
	return false
end

function TOOL:Think()
	/* // Disabled because i am unable to get the model of the current item
	local Mod = self:GetCurrentItemModel()
	if !self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != InsertModelHere then
		self:MakeGhostEntity(Mod,Vector(0,0,0),Angle(0,0,0))
	end
	self:UpdateGhost(self.GhostEntity,self:GetOwner())
	*/
end

function TOOL:UpdateGhost(ent,ply)
	if !ent or !ent:IsValid() then return end
	local trace = util.TraceLine(utilx.GetPlayerTrace(ply,ply:GetCursorAimVector()))
	if !trace.Hit or trace.Entity:IsPlayer() then
		ent:SetNoDraw(true)
		return
	end
	ent:SetPos(trace.HitPos+self:Offset(trace.HitNormal:Angle(),Vector(-12,13,0)))
	ent:SetAngles(trace.HitNormal:Angle())
	ent:SetNoDraw(false)
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header",{Text = "#Tool_wtib_generators_name",Description = "#Tool_wtib_generators_desc"})
	local tab = {}
	for k,v in pairs(Items) do
		tab[scripted_ents.GetStored(v).t.PrintName or v] = {wtib_generators_class = k}
	end
	CPanel:AddControl("ListBox",{Label = "#Items",MenuButton = false,Height = ScrH()/2,Options = tab})
	CPanel:AddControl("Checkbox",{Label = "#Nocollide if welded",Command = "wtib_generators_nocollide"})
end
