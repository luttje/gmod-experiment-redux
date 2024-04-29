Schema.util = Schema.util or {}
Schema.util.transactions = Schema.util.transactions or {}
Schema.util.throttles = Schema.util.throttles or {}

--- Converts Source Engine units (1 unit = 1 inch) to centimeters (1 unit = 2.54 cm)
--- @param unit any
--- @return unknown
function Schema.util.UnitToCentimeters(unit)
    return unit * 2.54
end

--- Converts a time in seconds to a short nice time format (e.g: 2s, 1m, 1h)
--- @param time number The time in seconds.
--- @return string
function Schema.util.GetNiceShortTime(time)
    local text = string.NiceTime(time)

    local parts = text:Split(" ")
    local last = parts[#parts]

	return parts[1] .. last:sub(1, 1):lower()
end

--- Creates a scope that allows only a single transaction to be active at a time.
--- @param scope string
--- @param callback fun(release: fun())
--- @param client? any If provided, the scope will be unique to the client.
--- @return boolean
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
		ix.util.SchemaErrorNoHalt("Schema.util.RunSingleWithinScope: " .. err .. "\n")
		release()
	end

	return true
end

--- Returns true if the throttle is active, otherwise false.
--- @param scope string
--- @param delay number
--- @param entity Entity? If provided, the throttle will be unique to the entity.
--- @return boolean, number?
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
--- @param boundsMin Vector
--- @param boundsMax Vector
--- @param relativePosition Vector
--- @param relativeAngles Angle
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
    --- @param text string
	--- @return string
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

    --- Replaces a material texture with another texture for all models/ui that use it.
    --- @param material IMaterial
    --- @param replacement IMaterial
	--- @param keyValues? table|number
    function Schema.util.ReplaceMaterialTexture(material, replacement, keyValues)
        local replacementTexture = replacement:GetTexture("$basetexture")

        material:SetTexture("$basetexture", replacementTexture)

        -- Since 'Material' also returns a number as the second return value, we want to make sure it's a table.
        if (istable(keyValues)) then
            for key, value in pairs(keyValues) do
                local valueType = type(value)
                if (valueType == "number") then
                    material:SetFloat(key, value)
                elseif (valueType == "VMatrix") then
                    material:SetMatrix(key, value)
                elseif (valueType == "string") then
                    material:SetString(key, value)
                elseif (valueType == "ITexture") then
                    material:SetTexture(key, value)
                elseif (valueType == "Vector") then
                    material:SetVector(key, value)
                else
                    error("Invalid value type for keyValues: " .. valueType)
                end
            end
        end
    end

	--- Returns the HTML of the requested HTML file.
	--- Use tools/generate-html.sh to convert the HTML files in html/ to the cl_html.generated.lua file.
	--- We do this so development of the HTML files is easier, because we get proper syntax highlighting.
	--- @param path string
	--- @return string
	function Schema.util.GetHtml(path)
		local allHtml = include(Schema.folder .. "/schema/cl_html.generated.lua")
		local html = allHtml[path]

		if (not html) then
			error("HTML file not found: " .. path)
		end

		return html
	end
end
