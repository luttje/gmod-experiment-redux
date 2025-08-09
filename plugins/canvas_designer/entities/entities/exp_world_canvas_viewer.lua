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
ENT.ShowPlayerInteraction = false
ENT.RenderGroup = RENDERGROUP_BOTH

local TIME_TO_DECAY = 60 * 60 * 3

-- Network variables for canvas data
function ENT:SetupDataTables()
	self:NetworkVar("String", "CanvasName")
	self:NetworkVar("Float", "CanvasScale")
	self:NetworkVar("Float", "CreationTime")
	self:NetworkVar("Float", "MaxAlpha")
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
		self:SetCanvasScale(0.2)
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
	function ENT:Initialize()
		self.canvasDesigner = nil
		self.lastCanvasData = ""
		self.lastCanvasSize = { width = 0, height = 0 }
	end

	function ENT:Think()
		-- Check if canvas data has changed
		local currentData = self:GetCanvasData()
		if (currentData ~= self.lastCanvasData) then
			self:UpdateCanvasDesigner()
			self.lastCanvasData = currentData
		end

		-- Check if canvas size has changed and update render bounds if needed
		if (self.canvasDesigner) then
			local canvasWidth, canvasHeight = self.canvasDesigner:GetSize()
			if (self.lastCanvasSize.width ~= canvasWidth or self.lastCanvasSize.height ~= canvasHeight) then
				self.lastCanvasSize.width = canvasWidth
				self.lastCanvasSize.height = canvasHeight
				self:UpdateRenderBounds()
			end
		end
	end

	function ENT:UpdateRenderBounds()
		local canvasWidth, canvasHeight

		if (self.canvasDesigner) then
			canvasWidth, canvasHeight = self.canvasDesigner:GetSize()
		else
			-- Default size when no canvas is loaded
			canvasWidth = PLUGIN.CANVAS_DEFAULT_WIDTH or 400
			canvasHeight = PLUGIN.CANVAS_DEFAULT_HEIGHT or 400
		end

		-- Apply the canvas scale to the render bounds
		local scale = self:GetCanvasScale()
		local scaledWidth = canvasWidth * scale
		local scaledHeight = canvasHeight * scale

		-- Set the render bounds so this keeps drawing for a player until the canvas edges are off screen
		-- Add some padding to ensure proper culling
		local padding = math.max(scaledWidth, scaledHeight) * 0.1
		self:SetRenderBounds(
			Vector(-scaledWidth / 2 - padding, -scaledHeight / 2 - padding, -padding),
			Vector(scaledWidth / 2 + padding, scaledHeight / 2 + padding, padding)
		)
	end

	function ENT:UpdateCanvasDesigner()
		local canvasData = self:GetCanvasData()

		if (not canvasData) then
			self.canvasDesigner = nil
			self:UpdateRenderBounds() -- Update bounds even when no canvas
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

		-- Update render bounds with new canvas data
		self:UpdateRenderBounds()
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
		cam.Start3D2D(screenPos, screenAng, scale)

		if (self.canvasDesigner) then
			local canvasWidth, canvasHeight = self.canvasDesigner:GetSize()

			local drawWidth = canvasWidth
			local drawHeight = canvasHeight

			-- Center the canvas
			local offsetX = -drawWidth * .5
			local offsetY = -drawHeight * .5

			self.canvasDesigner:DrawCanvas(offsetX, offsetY, drawWidth, drawHeight, true, true, currentAlpha)
		end

		cam.End3D2D()
	end
end
