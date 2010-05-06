ENT.Type			= "anim"
ENT.PrintName		= "Liquid Tiberium Storage Medium"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"LiquidTiberium")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Model = "models/Tiberium/medium_chemical_storage.mdl",
	PercentDelay = 0.04,
	Information =	{
						"Medium liquids storage",
						"\nThis object can store 3000 units of liquid Tiberium."
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
