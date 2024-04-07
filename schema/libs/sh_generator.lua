if(Schema.generator == nil)then
	Schema.generator = {}
	Schema.generator.stored = {}
end

function Schema.generator.Register(name, power, health, maximum, cash, uniqueID, powerName, powerPlural, upgrades)
	Schema.generator.stored[uniqueID] = {
		powerPlural = powerPlural or powerName or "Power",
		powerName = powerName or "Power",
		uniqueID = uniqueID,
		maximum = maximum or 5,
		health = health or 100,
		power = power or 2,
		cash = cash or 100,
		name = name,
		upgrades = upgrades or {}
	}
end

function Schema.generator.GetAll()
	return Schema.generator.stored
end

function Schema.generator.Get(name)
	if ( Schema.generator.stored[name] ) then
		return Schema.generator.stored[name]
	else
		local generator

		for k, v in pairs(Schema.generator.stored) do
			if ( string.find( string.lower(v.name), string.lower(name) ) ) then
				if (generator) then
					if ( string.len(v.name) < string.len(generator.name) ) then
						generator = v
					end
				else
					generator = v
				end
			end
		end

		return generator
	end
end

if (SERVER) then
	function Schema.generator.Spawn(generator, position, angles)
		local entity = ents.Create(generator.uniqueID)
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:Activate()

		return entity
	end
end
