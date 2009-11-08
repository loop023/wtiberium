
WTib_DynamicLight = CreateClientConVar("WTib_DynamicLight",1,true,true)
WTib_DynamicLightSize = CreateClientConVar("WTib_DynamicLightSize",1,true,true)
WTib_UseToolTips = CreateClientConVar("WTib_UseTooltips",1,true,true)
WTib_UseOldToolTips = CreateClientConVar("WTib_UseOldTooltips",1,true,true)

function WTib_ToolTipDraw()
	if !WTib_UseToolTips:GetBool() then return end
	local tr = LocalPlayer():GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity.WTib_GetTooltip and EyePos():Distance(tr.Entity:GetPos()) < 512 then
		local p = tr.HitPos
		if WTib_UseOldToolTips:GetBool() then
			p = tr.Entity:GetPos()
		end
		local tip = tr.Entity:WTib_GetTooltip()
		if tip and tip != "" then
			AddWorldTip(tr.Entity:EntIndex(),tip,0.5,p,self)
		end
	end
end
hook.Add("HUDPaint","WTib_ToolTipDraw",WTib_ToolTipDraw)

function WTib_ToolMenu()
	spawnmenu.AddToolMenuOption("Options","Performance","WTibClientSettings","WTib Settings","","",WTib_ClientPopulateMenu,{})
	spawnmenu.AddToolMenuOption("Options","Admin","WTibAdminSettings","WTib Settings","","",WTib_AdminPopulateMenu,{})
end
hook.Add("AddToolMenuCategories","WTib_ToolMenu",WTib_ToolMenu)

function WTib_ClientPopulateMenu(Panel)
	Panel:ClearControls()
	Panel:AddHeader()
	Panel:CheckBox("Use dynamic lights","WTib_DynamicLight"):SetToolTip("Frame Burst: High")
	Panel:AddControl("Slider",{	Label = "Dynamic light size",
								Command = "WTib_DynamicLightSize",
								Type = "Integer",
								Min = "1",
								Max = "10"})
	Panel:CheckBox("Use tool tips","WTib_UseTooltips"):SetToolTip("Frame Burst: Low")
	Panel:CheckBox("Use old tool tips","WTib_UseOldTooltips"):SetToolTip("Frame Burst: None")
end

function WTib_AdminPopulateMenu(Panel)
	Panel:ClearControls()
	Panel:AddHeader()
	if !LocalPlayer():IsAdmin() then
		return
	end
	Panel:AddControl("Slider",{	Label = "Max Tiberium field size",
								Command = "WTib_MaxFieldSize",
								Type = "Integer",
								Min = "30",
								Max = "300"})
	Panel:AddControl("Slider",{	Label = "Max Green Tiberium production rate",
								Command = "WTib_MaxGreenProductionRate",
								Type = "Integer",
								Min = "40",
								Max = "300"})
	Panel:AddControl("Slider",{	Label = "Min Green Tiberium production rate",
								Command = "WTib_MinGreenProductionRate",
								Type = "Integer",
								Min = "30",
								Max = "290"})
	Panel:AddControl("Slider",{	Label = "Max Blue Tiberium production rate",
								Command = "WTib_MaxBlueProductionRate",
								Type = "Integer",
								Min = "40",
								Max = "300"})
	Panel:AddControl("Slider",{	Label = "Min Blue Tiberium production rate",
								Command = "WTib_MinBlueProductionRate",
								Type = "Integer",
								Min = "30",
								Max = "290"})
	Panel:AddControl("Slider",{	Label = "Max Red Tiberium production rate",
								Command = "WTib_MaxRedProductionRate",
								Type = "Integer",
								Min = "40",
								Max = "300"})
	Panel:AddControl("Slider",{	Label = "Min Red Tiberium production rate",
								Command = "WTib_MinRedProductionRate",
								Type = "Integer",
								Min = "30",
								Max = "290"})
	Panel:CheckBox("Emit gas","WTib_ProduceGas"):SetToolTip("If the Tiberium should emit gas.")
	Panel:AddControl("Button",{	Text = "Remove all Tiberium",
								Command = "WTib_ClearAllTiberium"})
end

/*
	***************************************************
	*         Wire shit down here, these are all placeholders          *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_Render(a)
	if Wire_Render then
		Wire_Render(a)
	end
	if WTib_HasRD() then
		if WTib_HasRD3() then
			WTib_RD3.Beam_Render(a)
		end
	end
end

function WTib_UpdateRenderBounds(a)
	if WireAddon then
		return Wire_UpdateRenderBounds(a)
	end
end
