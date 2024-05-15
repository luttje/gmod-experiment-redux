ix.util._existingLibraries = ix.util._existingLibraries or {}

--- Gets an existing or creates a library that loads object types from a directory.
--- For example: Schema.buff, Schema.achievement, Schema.perk
--- which would then be loaded from the buffs, achievements, and perks directories.
---
--- Example usage:
--- Schema.achievement = ix.util.GetOrCreateCommonLibrary("Achievement")
--- @param libraryName string The unique name of the library.
--- @param constructor? fun(): table The constructor function for an object.
--- @return table # The library table.
function ix.util.GetOrCreateCommonLibrary(libraryName, constructor)
    local libraryGlobalName = libraryName:gsub("%s+", "_"):upper()

	local library = ix.util._existingLibraries[libraryName] or {}
    ix.util._existingLibraries[libraryName] = library

	library.stored = library.stored or {}
	library.buffer = library.buffer or {}

	library.GetBuffer = function()
		return library.buffer
	end

	library.GetAll = function()
		return library.stored
	end

	library.LoadFromDir = function(directory)
		local oldGlobal = _G[libraryGlobalName]

		for _, fileName in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
			local uniqueID = string.lower(fileName:sub(4, -5))
			local LIBRARY

            if (constructor) then
                LIBRARY = library.stored[uniqueID] or constructor()
            else
                LIBRARY = library.stored[uniqueID] or {}
            end

			LIBRARY.hooks = LIBRARY.hooks or {}

			_G[libraryGlobalName] = LIBRARY

			LIBRARY.uniqueID = uniqueID
			LIBRARY.index = tonumber(util.CRC(uniqueID))

			ix.util.Include(directory .. "/" .. fileName, "shared")

			if (SERVER) then
				if (LIBRARY.backgroundImage) then
					resource.AddFile("materials/" .. LIBRARY.backgroundImage .. ".vmt")
				end

				if (isstring(LIBRARY.foregroundImage)) then
					resource.AddFile("materials/" .. LIBRARY.foregroundImage .. ".vmt")
				elseif (istable(LIBRARY.foregroundImage)) then
					local spritesheetData = LIBRARY.foregroundImage

					if (spritesheetData.spritesheet:EndsWith(".png")) then
						resource.AddFile("materials/" .. spritesheetData.spritesheet)
					else
						resource.AddFile("materials/" .. spritesheetData.spritesheet .. ".vmt")
					end
				end
			else
				if (istable(LIBRARY.foregroundImage)) then
					local spritesheetData = LIBRARY.foregroundImage

					spritesheetData.spritesheet = Material(spritesheetData.spritesheet)
				end
			end

			-- Let libraries listen to hooks
			for hookName, hookCallback in pairs(LIBRARY.hooks) do
				if (isfunction(hookCallback)) then
					HOOKS_CACHE[hookName] = HOOKS_CACHE[hookName] or {}
					HOOKS_CACHE[hookName][LIBRARY] = hookCallback
				end
			end

			library.stored[LIBRARY.uniqueID] = LIBRARY
			library.buffer[LIBRARY.index] = LIBRARY
		end

		_G[libraryGlobalName] = oldGlobal
	end

	library.Get = function(name)
		if (library.buffer[name]) then
			return library.buffer[name]
		elseif (library.stored[name]) then
			return library.stored[name]
		else
			local foundObject

			for _, libraryObject in pairs(library.stored) do
				if (string.find(string.lower(libraryObject.name), string.lower(name))) then
					if (foundObject) then
						if (string.len(libraryObject.name) < string.len(foundObject.name)) then
							foundObject = libraryObject
						end
					else
						foundObject = libraryObject
					end
				end
			end

			return foundObject
		end
	end

	library.Exists = function(name)
		return library.Get(name) ~= nil
	end

	library.FindByProperty = function(key, value, handleLibraryValueAsPattern)
		local results = {}

        for _, libraryObject in pairs(library.stored) do
			local libraryValues = libraryObject[key]

            if (not libraryValues) then
                continue
            end

            if (not istable(libraryValues)) then
                libraryValues = { libraryValues }
            end

			for _, libraryValue in ipairs(libraryValues) do
                local matched = handleLibraryValueAsPattern
                    and string.find(value, libraryValue)
					or libraryValue == value

				if (matched) then
                    results[#results + 1] = libraryObject
					break
				end
			end
		end

		return results
	end

    library.GetProperty = function(name, key)
        local libraryObject = library.Get(name)

        if (not libraryObject or not libraryObject[key]) then
            error(libraryName .. " '" .. name .. "' does not have property '" .. key .. "'.")
        end

        return libraryObject[key]
    end

	return library
end

--- print, but with Experiment Redux prefix.
--- @vararg any
function ix.util.SchemaPrint(...)
	print("[Experiment Redux] " .. string.format(...))
end

--- ErrorNoHalt, but with Experiment Redux prefix.
--- @vararg any
function ix.util.SchemaErrorNoHalt(...)
	ErrorNoHalt("[Experiment Redux] ")

	for i = 1, select("#", ...) do
		local value = select(i, ...)

		ErrorNoHalt(tostring(value))
		ErrorNoHalt(" ")
	end

	ErrorNoHalt("\n")
end

--- ErrorNoHaltWithStack, but with Experiment Redux prefix.
--- @vararg any
function ix.util.SchemaErrorNoHaltWithStack(...)
	ErrorNoHalt("[Experiment Redux] ")

	for i = 1, select("#", ...) do
		local value = select(i, ...)

		ErrorNoHalt(tostring(value))
		ErrorNoHalt(" ")
	end

	ErrorNoHalt("\n")
	ErrorNoHalt(debug.traceback("", 2))
	ErrorNoHalt("\n")
end

--- error, but with Experiment Redux prefix.
--- @vararg any
function ix.util.SchemaError(...)
	error("[Experiment Redux] " .. string.format(...), 2)
end
