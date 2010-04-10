
if SERVER then
	AddCSLuaFile("sh_wtiberium.lua")
	AddCSLuaFile("client/cl_wtiberium.lua")
end

WTib = WTib or {}
WTib.Warheads = {}
WTib.Debug = false

/*
	Warhead functions
*/

function WTib.Warheads.GetWarhead(int)
	return ""
end

/*
	Debug things
*/

function WTib.DebugEffect(...)
	if WTib.Debug then
		util.Effect(...)
	end
end

function WTib.DebugPrint(...)
	if WTib.Debug then
		print(...)
	end
end

function WTib.DebugPrintTable(...)
	if WTib.Debug then
		PrintTable(...)
	end
end

/*
	Hooks
*/

function WTib.PhysPickup(ply,ent)
	if ent.IsTiberium then
		return false
	end
end
hook.Add("PhysgunPickup","WTib.PhysPickup",WTib.PhysPickup)

/*
	RD and Wire functions
*/

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

/*
	Misc things
*/

function WTib.Trace(...) // Make it stargate compatible later on maybe.
	return util.QuickTrace(...)
end

function WTib.GetClass(ent)
	return string.Replace(ent.Folder,"entities/","")
end
