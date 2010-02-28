
WTib = WTib or {}

WTib.DynamicLight = CreateClientConVar("WTib_DynamicLight",1,true,false)
WTib.DynamicLightSize = CreateClientConVar("WTib_DynamicLightSize",1,true,false)

WTib.UseToolTips = CreateClientConVar("WTib_UseTooltips",1,true,false)
WTib.ToolTipsRange = CreateClientConVar("WTib_ToolTipsRange",512,true,false)
WTib.UseOldToolTips = CreateClientConVar("WTib_UseOldTooltips",1,true,false)

function WTib.ToolTipDraw()
	if !WTib.UseToolTips:GetBool() then return end
	local tr = LocalPlayer():GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity.WTib_GetTooltip and EyePos():Distance(tr.Entity:GetPos()) < WTib.ToolTipsRange:GetInt() then
		local p = tr.HitPos
		if WTib.UseOldToolTips:GetBool() then
			p = tr.Entity:GetPos()
		end
		local tip = tr.Entity:WTib_GetTooltip()
		if tip and tip != "" then
			AddWorldTip(tr.Entity:EntIndex(),tip,0.5,p,self)
		end
	end
end
hook.Add("HUDPaint","WTib.ToolTipDraw",WTib.ToolTipDraw)
