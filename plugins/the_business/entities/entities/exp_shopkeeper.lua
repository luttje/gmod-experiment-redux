local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

ENT.Type = "anim"

ENT.PrintName = "Shopkeeper"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.AutomaticFrameAdvance = true

if (SERVER) then
    function ENT:Initialize()
        self:SetModel("models/experiment-redux/shopkeeper.mdl")

        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)

		self:SetUseType(SIMPLE_USE)

		self:ReturnToIdle()
    end

    function ENT:Use(activator)
		local isNowOpen = not self:GetNWBool("open", false)
        self:SetNWBool("open", isNowOpen)

        if (isNowOpen) then
            self:OneShotSequence("inspect", function()
				self:SetNWBool("open", false)
			end)
        end
    end

    function ENT:ReturnToIdle()
        self:ResetSequence(self:LookupSequence("idle"))
		self:SetCycle(0)
    end

    function ENT:OneShotSequence(sequenceName, callback)
        local sequence, duration = self:LookupSequence(sequenceName)

        self:ResetSequence(sequence)
		self:SetCycle(0)

        timer.Create("ResetToIdle" .. self:EntIndex(), duration, 1, function()
            if (not IsValid(self)) then
                return
            end

            self:ReturnToIdle()

			if (callback) then
				callback()
			end
		end)
	end

	function ENT:Think()
		self:NextThink(CurTime())
		return true -- Return true to let the game know we want to apply the self:NextThink() call
	end
end

if (not CLIENT) then
	return
end

local doorModel = Model("models/experiment-redux/shopkeeper_portal_door.mdl")

-- Draw the door model, running the open/close animation if needed.
function ENT:Draw()
    self:DrawModel()

	local door = self.door

	if (not IsValid(door)) then
        self.door = ClientsideModel(doorModel, RENDERGROUP_OPAQUE)
        door = self.door

        door:SetNoDraw(true)
        door:SetPlaybackRate(0.5)

        self.open = self:GetNWBool("open", false)
	end

	offset = self:GetUp() * 19 -- TODO: Match the doors origin to the shopkeeper model origin so we don't need to offset it.
	door:SetPos(self:GetPos() + offset)
	door:SetAngles(self:GetAngles())

    local open = self:GetNWBool("open", false)

    if (open) then
        if (self.open ~= true) then
            self.open = true
            door:SetSequence("open")
        end
    elseif (self.open) then
        self.open = false
        door:SetSequence("close")
    end

	door:FrameAdvance()
	door:DrawModel()
	render.RenderFlashlights(function()
		door:DrawModel()
	end)
end
