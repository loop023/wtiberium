
TOOL.Category		= "WTiberium"
TOOL.Name			= "#Weapons"
TOOL.Command		= nil
TOOL.ConfigName		= nil

local Items =	{
					"wtib_missilelauncher",
					"wtib_sonicfieldemitter"
				}

TOOL.ClientConVar["nocollide"]	= "0"
TOOL.ClientConVar["class"]		= "1"

if CLIENT then
	language.Add("Tool_wtib_weapons_name","WTib weapons tool")
	language.Add("Tool_wtib_weapons_desc","Use this tool to place WTib weapons.")
	language.Add("Tool_wtib_weapons_0","Left click to place the selected item\nRight click to place the selected item without welding")
	language.Add("Undone_wtib_weapons","Undone WTib weapon")
	language.Add("Cleaned_wtib_weapons","Cleaned up all WTib weapons")
	language.Add("SBoxLimit_wtib_weapons","You've reached the WTib weapons limit!")
end

function TOOL:LeftClick(t,noweld)
	if !t.Hit then return false end
	if !util.IsValidPhysicsObject(t.Entity,t.PhysicsBone) then return false end
	if !self:GetOwner():CheckLimit("wtib_weapons") then return false end
	local cl = Items[tonumber(self:GetClientNumber("class"))]
	if !cl then return false end
	// Everything is checked, we can now make the entity.
	local e = scripted_ents.GetStored(cl).t:SpawnFunction(self:GetOwner(),t)
	if !e then return false end
	if !SERVER then return true end
	e.WDSO = self:GetOwner()
	local weld
	self:GetOwner():AddCount("wtib_weapons",e)
	undo.Create("wtib_weapons")
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

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header",{Text = "#Tool_wtib_weapons_name",Description = "#Tool_wtib_weapons_desc"})
	local tab = {}
	for k,v in pairs(Items) do
		tab[scripted_ents.GetStored(v).t.PrintName or v] = {wtib_weapons_class = k}
	end
	CPanel:AddControl("ListBox",{Label = "#Items",MenuButton = false,Height = ScrH()/2,Options = tab})
	CPanel:AddControl("Checkbox",{Label = "#Nocollide if welded",Command = "wtib_weapons_nocollide"})
end
