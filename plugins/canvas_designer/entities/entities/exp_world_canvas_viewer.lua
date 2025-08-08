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

-- Network variables for canvas data
function ENT:SetupDataTables()
	self:NetworkVar("String", 1, "CanvasName")
	self:NetworkVar("Float", 0, "CanvasScale")
end

function ENT:GetCanvasData()
	return self:GetNetVar("data")
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

		-- Make it small and transparent for debugging
		self:SetModelScale(0.1)
		self:SetColor(Color(255, 0, 0, 100)) -- Semi-transparent red cube
	end

	function ENT:SetCanvasData(data)
		self:SetNetVar("data", data)
	end

	-- No Use function - removed interaction

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
		-- Minimal thinking for graffiti
		self:NextThink(CurTime() + 5) -- Less frequent updates
		return true
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
		if (not self.canvasDesigner) then
			local pos = self:GetPos()
			local ang = self:GetAngles()
			local screenPos = pos + ang:Up() * 1
			local screenAng = Angle(ang.p, ang.y, ang.r + 90)

			cam.Start3D2D(screenPos, screenAng, 0.1)
			draw.SimpleText("NO CANVAS DATA", "DermaLarge", 0, 0, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

			self.canvasDesigner:DrawCanvas(offsetX, offsetY, drawWidth, drawHeight, true, true, 0.6)
		end

		cam.End3D2D()
	end
end
