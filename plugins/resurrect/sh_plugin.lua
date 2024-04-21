local PLUGIN = PLUGIN

PLUGIN.name = "Resurrection"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Lets players resurrect other players."

-- if (CLIENT) then
-- 	function PLUGIN:NetworkEntityCreated(entity)
-- 		if (entity:GetClass() ~= "prop_ragdoll") then
-- 			return
-- 		end

-- 		entity.GetEntityMenu = function(entity, options)
-- 			local player = entity:GetNetVar("player", NULL)

-- 			if (not IsValid(player) or player:Alive()) then
-- 				return
-- 			end

-- 			-- TODO: Guard for if they haven't recently been resurrected (are debuff-ed)
-- 			local options = {}

-- 			options["resurrect"] = {
-- 				text = "Resurrect",
-- 				icon = "icon16/heart.png",
-- 			}

-- 			return options
-- 		end

-- 		print(entity.GetEntityMenu)
-- 	end
-- end

if (not SERVER) then
    return
end

-- function PLUGIN:PlayerInteractEntity(client, entity, option, data)
-- 	if (entity:GetClass() ~= "prop_ragdoll" or option ~= "resurrect") then
-- 		return
-- 	end

-- 	entity.OnOptionSelected = function(entity, client, option, data)
-- 		if (option ~= "resurrect") then
-- 			return
-- 		end

-- 		local player = entity:GetNetVar("player")

-- 		if (not IsValid(player) or player:Alive()) then
-- 			client:Notify("This corpse is beyond saving!")
-- 		end

-- 		-- TODO: Guard for if they haven't recently been resurrected (are debuff-ed)

-- 		-- TODO: Resurrect the player
-- 		print("todo", player, "resurrecting")
-- 	end
-- end
