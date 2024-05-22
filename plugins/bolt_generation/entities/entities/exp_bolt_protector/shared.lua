ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Bolt Protector"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ProtectedCount")
end
