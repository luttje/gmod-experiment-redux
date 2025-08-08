local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Canvas Viewer"
ENT.Category = "Experiment Redux"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.ShowPlayerInteraction = false -- Disabled interaction
ENT.RenderGroup = RENDERGROUP_BOTH

local TIME_TO_DECAY = 60 * 60 * 3

-- Network variables for canvas data
function ENT:SetupDataTables()
	self:NetworkVar("String", 1, "CanvasName")
	self:NetworkVar("Float", 0, "CanvasScale")
	self:NetworkVar("Float", 1, "CreationTime")
	self:NetworkVar("Float", 2, "MaxAlpha")
end

function ENT:GetCanvasData()
	return self:GetNetVar("data")
end

function ENT:GetCurrentAlpha()
	local creationTime = self:GetCreationTime()
	local maxAlpha = self:GetMaxAlpha()

	if (creationTime == 0) then
		return maxAlpha -- Fallback if creation time not set
	end

	local elapsed = CurTime() - creationTime
	local decayProgress = math.Clamp(elapsed / TIME_TO_DECAY, 0, 1)

	-- Linear decay from maxAlpha to 0
	return maxAlpha * (1 - decayProgress)
end

function ENT:ShouldDecay()
	local creationTime = self:GetCreationTime()
	if (creationTime == 0) then
		return false
	end

	local elapsed = CurTime() - creationTime
	return elapsed >= TIME_TO_DECAY
end

if (SERVER) then
	function ENT:Initialize()
		-- Use a small model for debugging
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:SetSolid(SOLID_NONE) -- No collision
		self:SetMoveType(MOVETYPE_NONE) -- Can't be moved

		-- Default settings
		self:SetCanvasScale(1.0)
		self:SetCanvasName("Graffiti Canvas")
		self:SetCreationTime(CurTime())
		self:SetMaxAlpha(0.6) -- Default max alpha
	end

	function ENT:SetCanvasData(data)
		self:SetNetVar("data", data)
	end

	-- Set canvas data from an item
	function ENT:SetCanvasFromItem(itemID)
		local itemTable = ix.item.instances[itemID]

		if (not itemTable) then
			return false
		end

		local designData = itemTable:GetData("design")
		if (not designData) then
			self:SetCanvasData("")
			self:SetCanvasName("Empty Canvas")
			return false
		end

		-- Serialize the design data for networking
		self:SetCanvasData(designData)
		self:SetCanvasName(itemTable:GetName())

		return true
	end

	function ENT:Think()
		-- Check if graffiti should decay and be removed
		if (self:ShouldDecay()) then
			self:Remove()
			return
		end

		-- Update thinking frequency based on decay progress
		local creationTime = self:GetCreationTime()

		if (creationTime > 0) then
			local elapsed = CurTime() - creationTime
			local decayProgress = elapsed / TIME_TO_DECAY

			-- Think more frequently as decay progresses for smoother transitions
			local thinkInterval = math.Clamp(5 - (decayProgress * 4), 0.5, 5)
			self:NextThink(CurTime() + thinkInterval)
		else
			self:NextThink(CurTime() + 5) -- Default interval
		end

		return true
	end

	-- Function to set custom max alpha (useful for different graffiti types)
	function ENT:SetMaxAlpha(alpha)
		self:SetNetVar("MaxAlpha", math.Clamp(alpha, 0, 1))
	end

	-- Function to reset decay timer (if needed)
	function ENT:ResetDecayTimer()
		self:SetCreationTime(CurTime())
	end
else
	local SCREEN_WIDTH = 512
	local SCREEN_HEIGHT = 512

	function ENT:Initialize()
		self.canvasDesigner = nil
		self.lastCanvasData = ""

		-- Set the render bounds so this keeps drawing for a player up until the canvas edges are off screen
		self:SetRenderBounds(
			Vector(-SCREEN_WIDTH / 2, -SCREEN_HEIGHT / 2, 0),
			Vector(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0)
		)
	end

	function ENT:Think()
		-- Check if canvas data has changed
		local currentData = self:GetCanvasData()
		if (currentData ~= self.lastCanvasData) then
			self:UpdateCanvasDesigner()
			self.lastCanvasData = currentData
		end
	end

	function ENT:UpdateCanvasDesigner()
		local canvasData = self:GetCanvasData()

		if (not canvasData) then
			self.canvasDesigner = nil
			return
		end

		-- Create a fake item for the canvas designer
		local fakeItem = {
			GetData = function(self, key)
				if (key == "design") then
					return canvasData
				end
				return nil
			end,
			GetName = function(self)
				return canvasData.name or "Canvas"
			end,
			GetID = function(self)
				return self.itemID or 0
			end,
		}

		-- Create canvas designer instance
		self.canvasDesigner = PLUGIN.CanvasDesigner:New(fakeItem)
	end

	function ENT:Draw()
		self:DrawCanvas3D2D()
	end

	function ENT:DrawCanvas3D2D()
		-- Get current alpha based on decay
		local currentAlpha = self:GetCurrentAlpha()

		-- Don't draw if completely transparent
		if (currentAlpha <= 0) then
			return
		end

		if (not self.canvasDesigner) then
			local pos = self:GetPos()
			local ang = self:GetAngles()
			local screenPos = pos + ang:Up() * 1
			local screenAng = Angle(ang.p, ang.y, ang.r + 90)

			cam.Start3D2D(screenPos, screenAng, 0.1)
			local textColor = Color(255, 0, 0, currentAlpha * 255)
			draw.SimpleText("NO CANVAS DATA", "DermaLarge", 0, 0, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
			return
		end

		local pos = self:GetPos()
		local ang = self:GetAngles()
		local scale = self:GetCanvasScale()

		-- Make it flush with the wall - minimal offset
		local screenPos = pos + ang:Forward() * 1 -- Small forward offset for visibility
		local screenAng = Angle(ang.p, ang.y, ang.r)

		screenAng:RotateAroundAxis(screenAng:Right(), 90)

		-- Start 3D2D context
		cam.Start3D2D(screenPos, screenAng, 0.1 * scale)

		if (self.canvasDesigner) then
			local canvasWidth, canvasHeight = self.canvasDesigner:GetSize()

			-- Scale canvas to fit screen
			local scaleX = SCREEN_WIDTH / canvasWidth * 0.9
			local scaleY = SCREEN_HEIGHT / canvasHeight * 0.9
			local drawScale = math.min(scaleX, scaleY)

			local drawWidth = canvasWidth * drawScale
			local drawHeight = canvasHeight * drawScale

			-- Center the canvas on screen
			local offsetX = -drawWidth / 2
			local offsetY = -drawHeight / 2

			self.canvasDesigner:DrawCanvas(offsetX, offsetY, drawWidth, drawHeight, true, true, currentAlpha)
		end

		cam.End3D2D()
	end
end
