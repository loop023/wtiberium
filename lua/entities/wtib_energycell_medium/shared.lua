ENT.Type			= "anim"
ENT.PrintName		= "Energy Cell Medium"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Model = "models/Tiberium/medium_energy_cell.mdl",
	PercentDelay = 0.03,
	Information =	{
						"Medium energy cell",
						"\nDesigned for medium energy storage."
					},
	CreateEnt = function(factory,angles,pos,id)
		local ent = ents.Create("wtib_energycell_medium")
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Factory.GetObjectByID(id).Model)
	end
})
