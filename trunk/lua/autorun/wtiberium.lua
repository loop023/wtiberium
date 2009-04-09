if SERVER then
	AddCSLuaFile("autorun/wtiberium.lua")
	AddCSLuaFile("autorun/client/cl_wtiberium.lua")
end

WTib_PickupBlock = true
WTib_NoPickupClasses =	{
							"wtib_missile"
						}

function WTib_PhysPickup(ply,ent)
	if WTib_PickupBlock and (ent.IsTiberium or table.HasValue(WTib_NoPickupClasses,ent:GetClass())) and !ent.DisableAntiPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_PhysPickup",WTib_PhysPickup)

function WTib_PhysgunPickupConsole(ply,con,args)
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	if !args[1] then
		WTib_PickupBlock = !(WTib_PickupBlock or true)
	else
		if args[1] == 0 then
			WTib_PickupBlock = false
		else
			WTib_PickupBlock = true
		end
	end
	local msg = "En"
	if WTib_PickupBlock then
		"Dis"
	end
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Physgun pickup on tiberium entities is now "..msg.."abled!")
	end
end
concommand.Add("WTib_PhysgunPickupBlock",WTib_PhysgunPickupConsole)
