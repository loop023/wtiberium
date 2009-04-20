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
	if !ent or !ent:IsValid() then return end
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
	local CustomWarhead = vgui.Create("DButton")
	CustomWarhead:SetParent(Frame)
	CustomWarhead:SetPos(40,435)
	CustomWarhead:SetSize(140,40)
	CustomWarhead:SetText("Make custom warhead")
	CustomWarhead.DoClick = function()
		WTib_OpenCustomWarheadMenu(ent)
		Frame:Close()
	end
	local Spawn = vgui.Create("DButton")
	Spawn:SetParent(Frame)
	Spawn:SetPos(220,435)
	Spawn:SetSize(140,40)
	Spawn:SetText("Spawn Warhead")
	Spawn.DoClick = function()
		RunConsoleCommand("wtib_spawnwarhead",tostring(ent))
	end
	local a = DList:AddColumn("Warhead :")
	a:SetWidth(30)
	DList:AddColumn("Discription :")
	for _,v in pairs(ent.Warheads) do
		DList:AddLine(v.name,v.Discription)
	end
	DList.OnRowSelected = function(panel,num)
		RunConsoleCommand("wtib_setwarhead",tostring(ent),num)
		surface.PlaySound("buttons/button9.wav")
	end
end
usermessage.Hook("WTib_OpenWarheadMenu",WTib_OpenWarheadMenu)

function WTib_OpenCustomWarheadMenu(ent)
	local En,RefTib,TibChem = 50,10,0
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(210,250)
	local w,h = 210,250
	Frame:SetPos((ScrW()/2)-(w/2),(ScrH()/2)-(h/2))
	Frame:SetTitle("Warhead Creation Menu")
	Frame:MakePopup()
	local TiberiumSlider = vgui.Create("DNumSlider",Frame)
	TiberiumSlider:SetPos(10,40)
	TiberiumSlider:SetSize(190,100)
	TiberiumSlider:SetText("Energy usage :")
	TiberiumSlider:SetMin(50)
	TiberiumSlider:SetMax(3000)
	TiberiumSlider:SetDecimals(0)
	TiberiumSlider.ValueChanged = function(a,b)
		En = math.Clamp(tonumber(b),50,3000)
	end
	local RefTiberiumSlider = vgui.Create("DNumSlider",Frame)
	RefTiberiumSlider:SetPos(10,80)
	RefTiberiumSlider:SetSize(190,100)
	RefTiberiumSlider:SetText("Amount of refined tiberium :")
	RefTiberiumSlider:SetMin(10)
	RefTiberiumSlider:SetMax(2000)
	RefTiberiumSlider:SetDecimals(0)
	RefTiberiumSlider.ValueChanged = function(a,b)
		RefTib = math.Clamp(tonumber(b),10,2000)
	end
	local TiberiumChemSlider = vgui.Create("DNumSlider",Frame)
	TiberiumChemSlider:SetPos(10,130)
	TiberiumChemSlider:SetSize(190,100)
	TiberiumChemSlider:SetText("Amount of tiberium chemicals :")
	TiberiumChemSlider:SetMin(0)
	TiberiumChemSlider:SetMax(1000)
	TiberiumChemSlider:SetDecimals(0)
	TiberiumChemSlider.ValueChanged = function(a,b)
		TibChem = math.Clamp(tonumber(b),0,1000)
	end
	local Confirm = vgui.Create("DButton")
	Confirm:SetParent(Frame)
	Confirm:SetPos(10,180)
	Confirm:SetSize(190,50)
	Confirm:SetText("Spawn Custom Warhead")
	Confirm.DoClick = function()
		print("wtib_spawncustomwarhead".." "..tostring(ent).." "..tostring(En).." "..tostring(RefTib).." "..tostring(TibChem))
		RunConsoleCommand("wtib_spawncustomwarhead",tostring(ent),tostring(En),tostring(RefTib),tostring(TibChem))
		Frame:Close()
	end
end
