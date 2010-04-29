include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	local B = "No"
	if self.dt.IsBuilding then
		B = "Yes"
	end
	return self.PrintName.."\nBuilding : "..B.."\nPercentage Complete : "..self.dt.PercentageComplete.."%"
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

usermessage.Hook("wtib_factory_openmenu",function(um)
	local Factory = um:ReadEntity()
	local Selected
	local MainBox = vgui.Create("DFrame")
	MainBox:SetSize(400,350)
	MainBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
	MainBox:SetTitle("Factory Menu")
	MainBox:SetVisible(true)
	MainBox:SetDraggable(false)
	MainBox:ShowCloseButton(false)
	MainBox:MakePopup()
	
	local BuildList = vgui.Create("DListView")
	BuildList:SetParent(MainBox)
	BuildList:SetPos(25,50)
	BuildList:SetSize(350,250)
	BuildList:SetMultiSelect(false)
	BuildList:AddColumn("ID")
	BuildList:AddColumn("Entity")
	BuildList:AddColumn("Build Time")
	BuildList.OnRowSelected = function(panel , line)
		Selected = BuildList:GetLine(line):GetValue(1)
	end
	
	for k,v in pairs(scripted_ents.Get("wtib_factory").Objects) do
		BuildList:AddLine(k,v.Name,tostring(100*v.PercentDelay).." seconds")
	end
	
	local ExitButton = vgui.Create("DButton")
	ExitButton:SetParent(MainBox)
	ExitButton:SetPos(40,310)
	ExitButton:SetSize(100,30)
	ExitButton:SetText("Close")
	ExitButton.DoClick = function(self)
		RunConsoleCommand("wtib_factory_closemenu",Factory:EntIndex())
		MainBox:Remove()
	end
	
	local InfoButton = vgui.Create("DButton")
	InfoButton:SetParent(MainBox)
	InfoButton:SetPos(150,310)
	InfoButton:SetSize(100,30)
	InfoButton:SetText("Info")
	InfoButton.DoClick = function(self)
		// Open info panel
	end
	
	local BuildButton = vgui.Create("DButton")
	BuildButton:SetParent(MainBox)
	BuildButton:SetPos(260,310)
	BuildButton:SetSize(100,30)
	BuildButton:SetText("Build")
	BuildButton.DoClick = function(self)
		RunConsoleCommand("wtib_factory_buildobject",Factory:EntIndex(),Selected)
		RunConsoleCommand("wtib_factory_closemenu",Factory:EntIndex())
		MainBox:Remove()
	end
end)
