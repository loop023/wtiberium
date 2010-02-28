ENT.Type			= "anim"
ENT.PrintName		= "Power Generator Medium"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

ENT.Resources =	{}
ENT.Resources[0] =	{
						Resource = "RawTiberium", // The resource type used by Resource Distribution
						Name = "Raw Tiberium", // The name shown in the tooltip
						Drain = 100, // The amount of this resource to drain
						Supply = 50 // THe amount of energy this it provides
					}
ENT.Resources[1] =	{
						Resource = "RefinedTiberium",
						Name = "Refined Tiberium",
						Drain = 70,
						Supply = 80
					}
ENT.Resources[2] =	{
						Resource = "ChemicalTiberium",
						Name = "Tiberium Chemicals",
						Drain = 10,
						Supply = 100
					}

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Type")
	self:DTVar("Int",1,"Resource")
	self:DTVar("Bool",0,"Online")
end

function ENT:GetTypeString()
	return self.Resources[self:GetType()].Resource
end

function ENT:GetTypeTable()
	return self.Resources[self:GetType()]
end

function ENT:GetType()
	return self.dt.Type
end
