killicon.Add("wtib_missile","killicons/wtib_missile_killicon",Color(255,80,0,255))

WTib_DynamicLight = CreateClientConVar("WTiberium_DynamicLights",1,true,true)
WTib_DynamicLightSize = 1

function WTib_DynamicLightsSizeConsole(ply,com,args)
	if !args[1] then
		print("Please specify the size!")
		return
	end
	WTib_DynamicLightSize = tonumber(args[1])
	LocalPlayer():ChatPrint("Dynamic lights size changed to "..tostring(WTib_DynamicLightSize))
end
concommand.Add("WTiberium_DynamicLightsSize",WTib_DynamicLightsSizeConsole)

function WTib_ToolTipDraw()
	local tr = LocalPlayer():GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity.WTib_GetTooltip then
		AddWorldTip(tr.Entity:EntIndex(),tr.Entity:WTib_GetTooltip(),0.5,tr.HitPos,self)
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