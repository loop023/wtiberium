include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib_Render(self)
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
		self.NextRBUpdate = CurTime()+2
		WTib_UpdateRenderBounds(self)
	end
end
language.Add("wtib_warheadfactory","Warhead Factory")

function ENT:WTib_GetTooltip()
	return "Warhead Factory\nCurrent Warhead : "..tostring(self:GetNWString("Warhead","None")).."\nEnergy : "..math.Round(tostring(self:GetNWInt("energy",0))).."\nRefined Tiberium : "..math.Round(tostring(self:GetNWInt("RefTib",0))).."\nTiberium Chemicals : "..math.Round(tostring(self:GetNWInt("TibChem",0)))
end

function WTib_OpenWarheadMenu(um)
	local ent = um:ReadEntity()
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(400,500)
	local w,h = 400,500
	Frame:SetPos((ScrW()/2)-(w/2),(ScrH()/2)-(h/2))
	Frame:SetTitle("Warhead selection menu")
	Frame:SetSizable(true)
	Frame:SetDeleteOnClose(true)
	Frame:MakePopup()
	local DList = vgui.Create("DListView")
	DList:SetParent(Frame)
	DList:SetPos(25,50)
	DList:SetSize(350,375)
	DList:SetMultiSelect(false)
	/*
	local CustomWarhead = vgui.Create("DButton")
	CustomWarhead:SetParent(Frame)
	CustomWarhead:SetPos(40,425)
	CustomWarhead:SetSize(100,40)
	CustomWarhead:SetText("Make custom warhead.")
	CustomWarhead.DoClick = function()
		WTib_OpenCustomWarheadMenu(ent)
		Frame:Close()
	end
	*/
	local a = DList:AddColumn("Warhead :")
	a:SetWidth(30)
	DList:AddColumn("Discription :")
	for _,v in pairs(ent.Warheads) do
		DList:AddLine(v.name,v.Discription)
	end
	DList.OnRowSelected = function(panel,num)
		print("Sending command : \"wtib_setwarhead \""..tostring(ent).."\" \""..num.."\"\"")
		RunConsoleCommand("wtib_setwarhead",tostring(ent),num)
		surface.PlaySound("buttons/button9.wav")
	end
end
usermessage.Hook("WTib_OpenWarheadMenu",WTib_OpenWarheadMenu)

function WTib_OpenCustomWarheadMenu(ent)
	local Tib,RTib,TibChem = 30,10,0
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(400,500)
	local w,h = 400,500
	Frame:SetPos((ScrW()/2)-(w/2),(ScrH()/2)-(h/2))
	Frame:SetTitle("Warhead Creation Menu")
	Frame:MakePopup()
	local TiberiumSlider = vgui.Create("DNumSlider",Frame)
	TiberiumSlider:SetPos(25,50)
	TiberiumSlider:SetSize(150,100)
	TiberiumSlider:SetText("Amount of tiberium :")
	TiberiumSlider:SetMin(30)
	TiberiumSlider:SetMax(3000)
	TiberiumSlider:SetDecimals(0)
	TiberiumSlider.ValueChanged = function(a,b)
		Tib = tonumber(b)
		print("Value Changed : "..tostring(a).." "..tostring(b))
	end
	local RefTiberiumSlider = vgui.Create("DNumSlider",Frame)
	RefTiberiumSlider:SetPos(25,50)
	RefTiberiumSlider:SetSize(150,100)
	RefTiberiumSlider:SetText("Amount of refined tiberium :")
	RefTiberiumSlider:SetMin(30)
	RefTiberiumSlider:SetMax(3000)
	RefTiberiumSlider:SetDecimals(0)
	RefTiberiumSlider.ValueChanged = function(a,b)
		RTib = tonumber(b)
		print("Value Changed : "..tostring(a).." "..tostring(b))
	end
	local TiberiumChemSlider = vgui.Create("DNumSlider",Frame)
	TiberiumChemSlider:SetPos(25,50)
	TiberiumChemSlider:SetSize(150,100)
	TiberiumChemSlider:SetText("Amount of tiberium :")
	TiberiumChemSlider:SetMin(30)
	TiberiumChemSlider:SetMax(3000)
	TiberiumChemSlider:SetDecimals(0)
	TiberiumChemSlider.ValueChanged = function(a,b)
		TibChem = tonumber(b)
		print("Value Changed : "..tostring(a).." "..tostring(b))
	end
end
