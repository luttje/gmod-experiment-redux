local PLUGIN = PLUGIN

if (SERVER) then
    AddCSLuaFile()
end

ENT.Type = "anim"
ENT.PrintName = "Structure Part"
ENT.IsStructurePart = true
ENT.PopulateEntityInfo = true

function ENT:GetUnderConstruction()
    local parent = self:GetParent()

    if (IsValid(parent)) then
        return parent:GetUnderConstruction()
    end

    return false
end

function ENT:OnPopulateEntityInfo(tooltip)
    local parent = self:GetParent()

    if (IsValid(parent)) then
		parent:OnPopulateEntityInfo(tooltip)
    end
end

function ENT:GetEntityMenu(client)
    local parent = self:GetParent()

    if (IsValid(parent)) then
		return parent:GetEntityMenu(client)
    end
end

if (SERVER) then
    function ENT:Initialize()
        self:SetMoveType(MOVETYPE_NONE)

        self:SetSolid(SOLID_VPHYSICS)

        -- Start off with no collision, we'll be attached to the player until we're fully constructed
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

        -- self:SetUseType(SIMPLE_USE) -- TODO: Repairability?
    end

    function ENT:OnTakeDamage(damageInfo)
        local parent = self:GetParent()

        if (IsValid(parent)) then
            parent:TakeDamage(damageInfo:GetDamage(), damageInfo:GetAttacker(), damageInfo:GetInflictor())
        end
    end

	function ENT:OnOptionSelected(client, option, data)
        local parent = self:GetParent()

        if (IsValid(parent)) then
			parent:OnOptionSelected(client, option, data)
		end
	end

	function ENT:Touch(entity)
		self.expIsTouched = true
	end
else
	function ENT:Draw()
		if (self:GetUnderConstruction()) then
			self:DrawModelOutline()
		else
			self:DrawModel()
		end
	end

	local wireframeMaterial = Material("models/wireframe")

	function ENT:DrawModelOutline()
		render.SuppressEngineLighting(true)
		render.MaterialOverride(wireframeMaterial)
		self:DrawModel()
		render.MaterialOverride()
		render.SuppressEngineLighting(false)
	end
end
