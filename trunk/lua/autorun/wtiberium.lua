if SERVER then
	AddCSLuaFile("autorun/wtiberium.lua")
	AddCSLuaFile("autorun/client/cl_wtiberium.lua")
end

local RD3
local HasRD

function WTib_PhysPickup(ply,ent)
	if ent.NoPhysicsPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_PhysPickup",WTib_PhysPickup)

function WTib_IsRD3()
	if(RD3 ~= nil) then return RD3 end
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		RD3 = true
		RD_3 = CAF.GetAddon("Resource Distribution")
		return true
	end
	RD3 = false
	return false
end

function WTib_HasRD()
	if !HasRD then
		HasRD = (Dev_Link != nil or #file.FindInLua("weapons/gmod_tool/stools/dev_link.lua") == 1)
	end
	return HasRD
end

function WTib_IsRD2()
	if WTib_IsRD3() then return false end
	return (Dev_Unlink_All != nil)
end
