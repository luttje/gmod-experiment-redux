Schema.util = Schema.util or {}
Schema.util.transactions = Schema.util.transactions or {}
Schema.util.throttles = Schema.util.throttles or {}

--- Converts Source Engine units (1 unit = 1 inch) to centimeters (1 unit = 2.54 cm)
---@param unit any
---@return unknown
function Schema.util.UnitToCentimeters(unit)
    return unit * 2.54
end

--- Converts a time in seconds to a short nice time format (e.g: 2s, 1m, 1h)
---@param time number The time in seconds.
---@return string
function Schema.util.GetNiceShortTime(time)
    local text = string.NiceTime(time)

    local parts = text:Split(" ")
    local last = parts[#parts]

	return parts[1] .. last:sub(1, 1):lower()
end

--- Creates a scope that allows only a single transaction to be active at a time.
---@param scope string
---@param callback fun(release: fun())
---@param client? any If provided, the scope will be unique to the client.
---@return boolean
function Schema.util.RunSingleWithinScope(scope, callback, client)
	if (client) then
		scope = scope .. "_" .. client:SteamID64()
	end

	if (Schema.util.transactions[scope] ~= nil) then
		return false
	end

	Schema.util.transactions[scope] = true

	local release = function()
		Schema.util.transactions[scope] = nil
	end

	local success, err = pcall(callback, release)

	if (not success) then
		ErrorNoHalt("Schema.util.RunSingleWithinScope: " .. err .. "\n")
		release()
	end

	return true
end

--- Returns true if the throttle is active, otherwise false.
---@param scope string
---@param delay number
---@param entity Entity? If provided, the throttle will be unique to the entity.
---@return boolean, number?
function Schema.util.Throttle(scope, delay, entity)
	local scopeTable = Schema.util.throttles

	if (entity) then
		scopeTable = entity.expThrottles or {}
		entity.expThrottles = scopeTable
	end

	if (scopeTable[scope] == nil) then
		scopeTable[scope] = CurTime() + delay

		return false
	end

	local throttled = scopeTable[scope] > CurTime()

	if (not throttled) then
        scopeTable[scope] = CurTime() + delay

		return false
	end

	return throttled, math.ceil(scopeTable[scope] - CurTime())
end

--- Expands the bounds of a cube to a list of points.
---@param boundsMin Vector
---@param boundsMax Vector
---@param relativePosition Vector
---@param relativeAngles Angle
function Schema.util.ExpandBoundsToCube(boundsMin, boundsMax, relativePosition, relativeAngles)
	local corners = {
		Vector(boundsMin.x, boundsMin.y, boundsMin.z),
		Vector(boundsMin.x, boundsMin.y, boundsMax.z),
		Vector(boundsMin.x, boundsMax.y, boundsMin.z),
		Vector(boundsMin.x, boundsMax.y, boundsMax.z),
		Vector(boundsMax.x, boundsMin.y, boundsMin.z),
		Vector(boundsMax.x, boundsMin.y, boundsMax.z),
		Vector(boundsMax.x, boundsMax.y, boundsMin.z),
		Vector(boundsMax.x, boundsMax.y, boundsMax.z),
	}

	local cube = {}

	for _, corner in ipairs(corners) do
		local relativeCornerPosition, relativeCornerAngles = LocalToWorld(corner, Angle(0, 0, 0), relativePosition, relativeAngles)

		table.insert(cube, relativeCornerPosition)
	end

	return cube
end

--- Traces from each corner of a cube to the first corner to see if it's colliding with anything
function Schema.util.TracePointsHit(points, filter, drawDebug)
	for k, corner in ipairs(points) do
		local trace = util.TraceLine({
			start = corner,
			endpos = points[1],
			filter = filter
		})

		if (drawDebug) then
			debugoverlay.Line(corner, trace.HitPos, 5, trace.Hit and Color(255, 0, 0) or Color(0, 255, 0), true)
		end

		if (trace.Hit) then
			return trace
		end
	end
end

if (CLIENT) then
    function Schema.util.RunInventoryAction(itemID, inventoryID, action, data)
        net.Start("ixInventoryAction")
        net.WriteString(action)
        net.WriteUInt(itemID, 32)
        net.WriteUInt(inventoryID, 32)
        net.WriteTable(data or {})
        net.SendToServer()
    end

    function Schema.util.LookupBinding(bind)
        local binding = input.LookupBinding(bind)

		if (not binding) then
			return nil
		end

		local translationKey = "bind_" .. binding:lower()
		local name = L(translationKey)

        return name ~= translationKey and name or binding:upper()
    end

    --- Finds bindings surrounded by curly braces and replaces them with their actual key.
    ---@param text string
	---@return string
    function Schema.util.ReplaceBindings(text)
        local replacement = text:gsub("{(.-)}", function(bind)
            return Schema.util.LookupBinding(bind) or ("{" .. bind .. "}")
        end)

        return replacement
    end

    --- Replaces all bindings in SWEP.Instructions
    function Schema.util.FillWeaponBindings()
		local allWeapons = weapons.GetList()

		for _, weapon in ipairs(allWeapons) do
			if (not weapon.Instructions) then
				continue
			end

			-- For weapons inside Helix, we replace them ourselves
			local instructions = weapon.Instructions
				:Replace("Primary Fire", "{+attack}")
				:Replace("Secondary Fire + Mouse", "{+attack2} + Move Mouse")
				:Replace("Secondary Fire", "{+attack2}")
				:Replace("Reload", "{+reload}")

			instructions = Schema.util.ReplaceBindings(instructions)
            weapons.GetStored(weapon.ClassName).Instructions = instructions

            -- If the player has the weapon equipped, we update the weapon's instructions
			local weaponEntity = LocalPlayer():GetWeapon(weapon.ClassName)

			if (IsValid(weaponEntity)) then
				weaponEntity.Instructions = instructions
			end
		end
    end

	hook.Add("InitPostEntity", "expFillWeaponBindingsOnInitialize", Schema.util.FillWeaponBindings)
	hook.Add("OnReloaded", "expFillWeaponBindingsOnReloaded", Schema.util.FillWeaponBindings)

	--- Draws a circle on the screen.
    -- Source: https://wiki.facepunch.com/gmod/surface.DrawPoly
    ---@param x number
    ---@param y number
    ---@param radius number
	---@param seg number
    function Schema.util.DrawCircle(x, y, radius, seg)
        local cir = {}

        table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
        for i = 0, seg do
            local a = math.rad((i / seg) * -360)
            table.insert(cir,
                { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) /
                2 + 0.5 })
        end

        local a = math.rad(0) -- This is needed for non absolute segment counts
        table.insert(cir,
            { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 +
            0.5 })

        surface.DrawPoly(cir)
    end

    --- Draws part of a spritesheet
    ---@param spritesheet IMaterial
    ---@param x number Where to draw the spritesheet part on the X axis.
    ---@param y number Where to draw the spritesheet part on the Y axis.
    ---@param w number How wide the drawn spritesheet part should be.
    ---@param h number How tall the drawn spritesheet part should be.
    ---@param partX number The X position (starting at 0) of the part (not in pixels, but in parts).
    ---@param partY number The Y position (starting at 0) of the part.
    ---@param partW number The width of each part in the spritesheet.
    ---@param partH number The height of each part in the spritesheet.
	---@param mirror? boolean Whether to mirror the spritesheet part.
    function Schema.util.DrawSpritesheetMaterial(spritesheet, x, y, w, h, partX, partY, partW, partH, mirror)
        local spritesheetWidth, spritesheetHeight = spritesheet:Width(), spritesheet:Height()
        local spriteX, spriteY = spritesheetWidth / partW, spritesheetHeight / partH
        local u = partX / spriteX
        local v = partY / spriteY
        local u2 = (partX + 1) / spriteX
        local v2 = (partY + 1) / spriteY

        if (mirror) then
            u, u2 = u2, u
        end

        surface.SetMaterial(spritesheet)
        surface.DrawTexturedRectUV(x, y, w, h, u, v, u2, v2)
    end

    --- Shows a spritesheet picker to get the x and y position of a spritesheet part.
    concommand.Add("debug_spritesheet_picker", function(client, command, arguments)
        if (not client:IsSuperAdmin()) then
            return
        end

		if (#arguments < 1) then
			arguments[1] = "experiment-redux/flatmsicons32.png"
		end

		local spritesheetPath = arguments[1]
		local spritesheet = Material(spritesheetPath)

		if (spritesheet:IsError()) then
			ErrorNoHalt("Invalid spritesheet path.\n")
			return
		end

        if (IsValid(ix.gui.debugSpritesheetPicker)) then
            ix.gui.debugSpritesheetPicker:Remove()
        end

        local frame = vgui.Create("DFrame")
		ix.gui.debugSpritesheetPicker = frame
		frame:SetSize(math.min(ScrW(), spritesheet:Width() + 8), math.min(ScrH(), spritesheet:Height() + 8))
		frame:Center()
		frame:SetTitle("Spritesheet Picker")
        frame:MakePopup()

        local spriteWidthLabel = frame:Add("DLabel")
        spriteWidthLabel:Dock(TOP)
        spriteWidthLabel:SetText("Sprite Width:")
		spriteWidthLabel:SizeToContents()

        local spriteWidthInput = frame:Add("DTextEntry")
        spriteWidthInput:Dock(TOP)
        spriteWidthInput:SetValue("32")

        local spriteHeightLabel = frame:Add("DLabel")
        spriteHeightLabel:Dock(TOP)
        spriteHeightLabel:SetText("Sprite Height:")
		spriteHeightLabel:SizeToContents()

        local spriteHeightInput = frame:Add("DTextEntry")
        spriteHeightInput:Dock(TOP)
        spriteHeightInput:SetValue("32")

        local spriteSizeButton = frame:Add("DButton")
        spriteSizeButton:Dock(TOP)
        spriteSizeButton:SetText("Set Sprite Size")

        local scroll = frame:Add("DScrollPanel")
        scroll:Dock(FILL)

        local output = frame:Add("DTextEntry")
		output:SetTall(100)
		output:SetMultiline(true)
        output:Dock(BOTTOM)

        local spriteWidth, spriteHeight = tonumber(spriteWidthInput:GetValue()), tonumber(spriteHeightInput:GetValue())
        local selectedSpriteX, selectedSpriteY = 0, 0

		function output:DoRefresh()
            local spriteDimensions

			if (spriteWidth == spriteHeight) then
				spriteDimensions = "size = " .. spriteWidth
			else
				spriteDimensions = "w = " .. spriteWidth .. ", h = " .. spriteHeight
			end

			local outputText = [[{
				spritesheet = "]] ..spritesheetPath .. [[",
				x = ]] .. selectedSpriteX .. [[,
				y = ]] .. selectedSpriteY .. [[,
				]] .. spriteDimensions .. [[,
			}]]

			self:SetText(outputText)
		end

        local spritesheetImage = scroll:Add("DImage")
		spritesheetImage:SetMaterial(spritesheet)
        spritesheetImage:Dock(TOP)

        local aspectRatio = spritesheet:Height() / spritesheet:Width()
        local scaleX, scaleY = 1, 1
		output:DoRefresh()

		spritesheetImage.Think = function(self)
            local scaledHeight = spritesheetImage:GetWide() * aspectRatio

            scaleX = spritesheetImage:GetWide() / spritesheet:Width()
			scaleY = scaledHeight / spritesheet:Height()

			if (scaledHeight ~= spritesheetImage:GetTall()) then
				spritesheetImage:SetTall(scaledHeight)
			end
		end

		spriteSizeButton.DoClick = function()
			spriteWidth = tonumber(spriteWidthInput:GetValue())
            spriteHeight = tonumber(spriteHeightInput:GetValue())
		end

		local spritePicker = scroll:Add("EditablePanel")
        spritePicker:SetSize(spritesheet:Width(), spritesheet:Height())
        spritePicker.Paint = function(self, w, h)
            local partX = selectedSpriteX
            local partY = selectedSpriteY

            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawOutlinedRect(partX * spriteWidth * scaleX, partY * spriteHeight * scaleY, spriteWidth * scaleX, spriteHeight * scaleY)
		end

		spritePicker.OnMousePressed = function(self, code)
            local x, y = self:CursorPos()
            local partX = math.floor(x / (spriteWidth * scaleX))
            local partY = math.floor(y / (spriteHeight * scaleY))

            selectedSpriteX = partX
            selectedSpriteY = partY

			output:DoRefresh()
		end
	end)
end
