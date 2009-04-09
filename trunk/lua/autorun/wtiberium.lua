if SERVER then
	AddCSLuaFile("autorun/wtiberium.lua")
	AddCSLuaFile("autorun/client/cl_wtiberium.lua")
end

WTib_NoPickupClasses =	{
							"wtib_missile"
						}

function WTib_PhysPickup(ply,ent)
	if (ent.IsTiberium or table.HasValue(WTib_NoPickupClasses,ent:GetClass())) and !ent.DisableAntiPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_PhysPickup",WTib_PhysPickup)
