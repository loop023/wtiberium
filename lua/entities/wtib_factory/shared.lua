ENT.Type			= "anim"
ENT.PrintName		= "Factory"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
	self:DTVar("Int",1,"RawTiberium")
	self:DTVar("Int",2,"BuildingID")
	self:DTVar("Int",3,"PercentageComplete")
	self:DTVar("Bool",0,"IsBuilding")
	self:DTVar("Entity",0,"CurObject")
end

ENT.Objects = {}
ENT.Objects[1] =	{
						Name = "Tiberium harvester medium",
						Model = "models/Tiberium/medium_harvester.mdl",
						PercentDelay = 0.04,
						CreateEnt = function(factory,angles,pos,id)
							local ent = ents.Create("wtib_harvester_medium")
							ent:SetPos(pos)
							ent:SetAngles(angles)
							ent:SetModel(factory.Objects[id].Model)
							ent:Spawn()
							ent:Activate()
						end
					}

hook.Add("CanPhysgunPickup","WTib_Factory_CanPickupEnt",function(ply,ent)
	if ent:GetClass() == "wtib_factory_object" then
		return false
	end
end)
