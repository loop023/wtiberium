
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

/*
	***************************************************
	*         Wire shit down here, these are all placeholders          *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_Render(a)
	if WireAddon then
		return Wire_Render(a)
	end
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.Beam_Render(a)
		end
	end
end

function WTib_UpdateRenderBounds(a)
	if WireAddon then
		return Wire_UpdateRenderBounds(a)
	end
end