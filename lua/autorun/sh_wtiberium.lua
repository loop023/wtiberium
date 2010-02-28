
if SERVER then
	AddCSLuaFile("sh_wtiberium.lua")
	AddCSLuaFile("client/cl_wtiberium.lua")
end

WTib = WTib or {}

function WTib.PhysPickup(ply,ent)
	if ent.IsTiberium then
		return false
	end
end
hook.Add("PhysgunPickup","WTib.PhysPickup",WTib.PhysPickup)

function WTib.Trace(...)
	return util.QuickTrace(...)
end

function WTib.HasRD2()
	return RD2Version != nil
end

function WTib.HasRD3()
	if WTib.RD3 != nil then return WTib.RD3 != nil end
	if CAF then
		if CAF.Addons then
			if (CAF.Addons.Get("Resource Distribution")) then
				WTib.RD3 = CAF.Addons.Get("Resource Distribution")
				return true
			end
		else
			if CAF and CAF.GetAddon and CAF.GetAddon("Resource Distribution") then
				WTib.RD3 = CAF.GetAddon("Resource Distribution")
				return true
			end
		end
	end
	return false
end
