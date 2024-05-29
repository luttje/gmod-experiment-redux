DEFINE_BASECLASS("base_ai")

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Experiment Monster Base"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.AutomaticFrameAdvance = true

-- Override this to return the display name of the monster
function ENT:GetDisplayName()
	return Format("monster")
end

hook.Add("ShouldCollide", "expDontCollideMonsters", function(entity, otherEntity)
    if (entity:IsNPC() and otherEntity:IsNPC()) then
		return false
	end
end)
