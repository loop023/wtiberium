ENT.Type			= "anim"
ENT.PrintName		= "Harvester Medium"
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
	self:DTVar("Bool",0,"Online")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Model = "models/Tiberium/medium_harvester.mdl",
	PercentDelay = 0.05,
	Information =	{
						"Medium harvester",
						"\nThis medium harvester harvests Tiberium in a moderate sized cone infront of it."
					},
	CreateEnt = function(factory,angles,pos,id)
		local ent = ents.Create("wtib_harvester_medium")
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Factory.GetObjectByID(id).Model)
	end
})
