
TOOL.Category		= "WTiberium"
TOOL.Name			= "#Storage tanks"
TOOL.Command		= nil
TOOL.ConfigName		= nil

local Items =	{
					"wtib_largeenergystorage",
					"wtib_mediumenergystorage",
					"wtib_smallenergystorage",
					"wtib_tinyenergystorage",
					"wtib_largechemtibstorage",
					"wtib_mediumchemtibstorage",
					"wtib_smallchemtibstorage",
					"wtib_tinychemtibstorage",
					"wtib_largereftibstorage",
					"wtib_mediumreftibstorage",
					"wtib_smallreftibstorage",
					"wtib_tinyreftibstorage",
					"wtib_largetibstorage",
					"wtib_mediumtibstorage",
					"wtib_smalltibstorage",
					"wtib_tinytibstorage"
				}

TOOL.ClientConVar["nocollide"]	= "0"
TOOL.ClientConVar["class"]		= "1"

if CLIENT then
	language.Add("Tool_wtib_storage_name","WTib storage tool")
	language.Add("Tool_wtib_storage_desc","Use this tool to place WTib storage tanks.")
	language.Add("Tool_wtib_storage_0","Left click to place the selected item\nRight click to place the selected item without welding")
	language.Add("Undone_wtib_storage","Undone WTib storage tank")
	language.Add("Cleaned_wtib_storage","Cleaned up all WTib storage tanks")
	language.Add("SBoxLimit_wtib_storage","You've reached the WTib storage tanks limit!")
end

function TOOL:LeftClick(t,noweld)
	if !t.Hit then return false end
	if !util.IsValidPhysicsObject(t.Entity,t.PhysicsBone) then return false end
	if !self:GetOwner():CheckLimit("wtib_storage") then return false end
	local cl = Items[tonumber(self:GetClientNumber("class"))]
	if !cl then return false end
	// Everything is checked, we can now make the entity.
	local e = scripted_ents.GetStored(cl).t:SpawnFunction(self:GetOwner(),t)
	if !e then return false end
	if !SERVER then return true end
	e.WDSO = self:GetOwner()
	local weld
	self:GetOwner():AddCount("wtib_storage",e)
	undo.Create("wtib_storage")
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
	CPanel:AddControl("Header",{Text = "#Tool_wtib_storage_name",Description = "#Tool_wtib_storage_desc"})
	local tab = {}
	for k,v in pairs(Items) do
		tab[scripted_ents.GetStored(v).t.PrintName or v] = {wtib_storage_class = k}
	end
	CPanel:AddControl("ListBox",{Label = "#Items",MenuButton = false,Height = ScrH()/2,Options = tab})
	CPanel:AddControl("Checkbox",{Label = "#Nocollide if welded",Command = "wtib_storage_nocollide"})
end
