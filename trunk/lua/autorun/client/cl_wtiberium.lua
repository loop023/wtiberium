killicon.Add("wtib_missile","killicons/wtib_missile_killicon",Color(255,80,0,255))

WTib_DynamicLight = CreateClientConVar("WTiberium_DynamicLights",1,true,true)
WTib_DynamicLightSize = CreateClientConVar("WTiberium_DynamicLightsSize",1,true,true)
WTib_UseToolTips = CreateClientConVar("WTiberium_UseTooltips",1,true,true)
WTib_UseOldToolTips = CreateClientConVar("WTiberium_UseOldTooltips",1,true,true)

function WTib_ToolTipDraw()
	if !WTib_UseToolTips:GetBool() then return end
	local tr = LocalPlayer():GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity.WTib_GetTooltip then
		local p = tr.HitPos
		if WTib_UseOldToolTips:GetBool() then
			p = tr.Entity:GetPos()
		end
		AddWorldTip(tr.Entity:EntIndex(),tr.Entity:WTib_GetTooltip(),0.5,p,self)
	end
end
hook.Add("Think","WTib_ToolTipDraw",WTib_ToolTipDraw)

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
end

function WTib_UpdateRenderBounds(a)
	if WireAddon then
		return Wire_UpdateRenderBounds(a)
	end
end