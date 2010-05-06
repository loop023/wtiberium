ENT.Type			= "anim"
ENT.PrintName		= "Chemical Plant Medium"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
	self:DTVar("Int",1,"RefinedTiberium")
	self:DTVar("Bool",0,"Online")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Model = "models/Tiberium/chemical_plant.mdl",
	PercentDelay = 0.15,
	Information =	{
						"Medium chemical plant",
						"\nThis factory converts refined Tiberium into Tiberium chemicals."
					},
	CreateEnt = function(factory,angles,pos,id)
		local ent = ents.Create("wtib_chemicalplant_medium")
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Factory.GetObjectByID(id).Model)
	end
})
