include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	Wire_Render(self)
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
	    self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self)
	end
end
language.Add("wtib_warheadfactory","Warhead Factory")

function WTib_OpenWarheadMenu(um)
	local ent = um:ReadEntity()
	local Frame = vgui.Create("DFrame")
	Frame:SetPos(100,100)
	Frame:SetSize(400,500)
	Frame:SetTitle("Warhead selection menu")
	Frame:MakePopup()
	local DList = vgui.Create("DListView")
	DList:SetParent(Frame)
	DList:SetPos(25,50)
	DList:SetSize(350,375)
	DList:SetMultiSelect(false)
	local CustomWarhead = vgui.Create("DButton")
	CustomWarhead:SetParent(Frame)
	CustomWarhead:SetPos(25,400)
	CustomWarhead:SetSize(100,40)
	CustomWarhead:SetText("Make custom warhead.")
	CustomWarhead.OnClick = function()
		WTib_OpenCustomWarheadMenu(ent)
		Frame:Close()
	end
	local a = DList:AddColumn("Warhead :")
	a:SetWidth(40)
	DList:AddColumn("Discription :")
	for _,v in pairs(ent.Warheads) do
		DList:AddLine(v.name,v.Discription)
	end
	DList.OnRowSelected = function(panel,num)
		print("Sending command : \"wtib_setwarhead "..tostring(ent).." "..num.."\"")
		RunConsoleCommand("wtib_setwarhead",tostring(ent),num)
		surface.PlaySound("buttons/button9.wav")
	end
end
usermessage.Hook("WTib_OpenWarheadMenu",WTib_OpenWarheadMenu)

function WTib_OpenCustomWarheadMenu(ent)
	
end
