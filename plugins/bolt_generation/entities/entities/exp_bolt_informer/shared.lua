ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Bolt Informer"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ProtectedCount")
end
