if SERVER then
	AddCSLuaFile("autorun/wtiberium.lua")
	AddCSLuaFile("autorun/client/cl_wtiberium.lua")
end

function WTib_PhysPickup(ply,ent)
	if ent.NoPhysicsPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_PhysPickup",WTib_PhysPickup)

function WTib_HasRD2()
	return RD2Version == 0
end

function WTib_HasRD3()
	if WTib_RD3 != nil then return true end
	if CAF then
		if CAF.Addons then
			if (CAF.Addons.Get("Resource Distribution")) then
				WTib_RD3 = CAF.Addons.Get("Resource Distribution")
				return true
			end
		else
			if CAF and CAF.GetAddon and CAF.GetAddon("Resource Distribution") then
				WTib_RD3 = CAF.GetAddon("Resource Distribution")
				return
			end
		end
	end
	WTib_RD3 = false
	return false
end

function WTib_HasRD()
	return WTib_HasRD3() or WTib_HasRD2()
end
