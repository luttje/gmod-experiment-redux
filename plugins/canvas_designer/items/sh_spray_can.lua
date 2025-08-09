local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Spray Can"
ITEM.price = 100
ITEM.shipmentSize = 10
ITEM.noBusiness = true -- Disabled for now
ITEM.model = "models/sprayca2.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Art"
ITEM.description = "A spray can filled with vibrant paint. Use it to create graffiti art on surfaces."
ITEM.maxUses = 10 -- Maximum uses before it runs out
ITEM.maximumGraffiti = 10

-- Add name function to show loaded design
function ITEM:GetName()
	local designData = self:GetData("design")

	if (designData and designData.name) then
		return self.name .. " (" .. designData.name .. ")"
	end

	return CLIENT and L(self.name) or self.name
end

-- Add tooltip to show design status
if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local designData = self:GetData("design")

		if (designData) then
			local panel = tooltip:AddRowAfter("name", "design_status")
			panel:SetBackgroundColor(PLUGIN.THEME.success)
			panel:SetText("Design: " .. (designData.name or "Unnamed"))
			panel:SizeToContents()
		else
			local panel = tooltip:AddRowAfter("name", "design_status")
			panel:SetBackgroundColor(PLUGIN.THEME.warning)
			panel:SetText("No Design Loaded")
			panel:SizeToContents()
		end

		local usesUsed = self:GetData("uses_used", 0)
		local usesLeft = self.maxUses - usesUsed

		local panel = tooltip:AddRowAfter("design_status", "uses_status")
		panel:SetBackgroundColor(PLUGIN.THEME.primary)
		panel:SetText("Uses Left: " .. usesLeft)
		panel:SizeToContents()
	end
end

-- Use Design function - loads a design from a canvas
ITEM.functions.UseDesign = {
	name = "Use Design",
	tip = "Load a design from a canvas into this spray can.",
	icon = "icon16/page_go.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("expSprayCanDesignSelector")
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		return item.player:GetCharacter() and item.invID == item.player:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.SpawnInWorld = {
	name = "Spray Graffiti",
	tip = "Spray this artwork as graffiti on a wall.",
	icon = "icon16/paintbrush.png",
	OnRun = function(item)
		if (SERVER) then
			local client = item.player
			local trace = client:GetEyeTrace()

			-- Make sure we hit something and it's not too far
			if (not trace.Hit) then
				client:Notify("You need to aim at a wall!")
				return false
			end

			-- Check distance - must be within 256 units
			local hitDistance = trace.StartPos:DistToSqr(trace.HitPos)

			if (hitDistance > 256 ^ 2) then
				client:Notify("You're too far from the wall! Get closer.")
				return false
			end

			if (client:IsObjectLimited("graffiti", item.maximumGraffiti)) then
				client:Notify(
					"You can not spray graffiti as you have reached the maximum amount of graffiti in the world!")
				return false
			end

			-- Position the graffiti on the surface
			local spawnPos = trace.HitPos + trace.HitNormal * 2
			local surfaceNormal = trace.HitNormal
			local playerPos = client:GetPos()

			-- Start with surface normal to make graffiti flush with any surface
			local angles = surfaceNormal:Angle()

			-- Make graffiti face outward from surface
			angles:RotateAroundAxis(angles:Up(), 180)

			-- Calculate direction to player projected onto the surface
			local toPlayer = (playerPos - spawnPos):GetNormalized()

			-- Project player direction onto the surface plane
			local surfaceRight = angles:Right()
			local surfaceUp = angles:Up()

			-- Get the component of player direction along the surface
			local rightComponent = toPlayer:Dot(surfaceRight)
			local upComponent = toPlayer:Dot(surfaceUp)

			-- Calculate rotation angle to face player (on the surface plane)
			local rotationAngle = math.atan2(upComponent, rightComponent) * (180 / math.pi)

			-- Rotate around the surface normal to face toward player
			angles:RotateAroundAxis(surfaceNormal, rotationAngle)

			-- Validate surface at all 4 corners of the canvas
			-- TODO: Get this from the canvas design
			local canvasSize = 64
			local halfSize = canvasSize * .5

			-- Get the four corner positions relative to the canvas center
			local right = angles:Right()
			local up = angles:Up()

			local corners = {
				spawnPos + right * halfSize + up * halfSize, -- Top right
				spawnPos - right * halfSize + up * halfSize, -- Top left
				spawnPos + right * halfSize - up * halfSize, -- Bottom right
				spawnPos - right * halfSize - up * halfSize -- Bottom left
			}

			-- Check each corner
			for i, cornerPos in ipairs(corners) do
				-- Trace from slightly behind the surface to slightly in front
				local startPos = cornerPos - surfaceNormal * 10
				local endPos = cornerPos + surfaceNormal * 20

				local cornerTrace = util.TraceLine({
					start = startPos,
					endpos = endPos,
					filter = client
				})

				-- Check if we hit something at this corner
				if (not cornerTrace.Hit) then
					client:Notify("Cannot place graffiti where it wouldn't fit the surface!")
					return false
				end
			end

			-- All validation passed, create the entity
			local entity = ents.Create("exp_world_canvas_viewer")
			entity:SetPos(spawnPos)
			entity:SetAngles(angles)
			entity:Spawn()

			entity:SetCanvasFromItem(item:GetID())

			client:AddLimitedObject("graffiti", entity)
			client:RegisterEntityToRemoveOnLeave(entity)

			item:SetData("uses_used", (item:GetData("uses_used", 0) or 0) + 1)

			client:Notify("Graffiti sprayed!")
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		local designData = item:GetData("design")

		if (not designData) then
			return false
		end

		return designData and item.player:GetCharacter() and
			item.invID == item.player:GetCharacter():GetInventory():GetID()
	end
}
