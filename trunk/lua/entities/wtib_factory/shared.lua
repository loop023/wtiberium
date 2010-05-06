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
	self:DTVar("Int",0,"BuildingID")
	self:DTVar("Int",1,"PercentageComplete")
	self:DTVar("Bool",0,"IsBuilding")
	self:DTVar("Entity",0,"CurObject")
end

ENT.Objects = {}
ENT.Objects[1] =	{
						Name = "Tiberium harvester medium",
						Model = "models/Tiberium/medium_harvester.mdl",
						PercentDelay = 0.04,
						Information =	{
											"Test Information1",
											"More Test information",
											"And more if you dont mind",
											"MultiLine information :\nHai, i am the second line"
										},
						CreateEnt = function(factory,angles,pos,id)
							local ent = ents.Create("wtib_harvester_medium")
							ent:SetPos(pos)
							ent:SetAngles(angles)
							ent:SetModel(factory.Objects[id].Model)
							ent:Spawn()
							ent:Activate()
						end
					}

hook.Add("PhysgunPickup","WTib_Factory_CanPickupEnt",function(ply,ent)
	if ent:GetClass() == "wtib_factory_object" then
		return false
	end
end)
