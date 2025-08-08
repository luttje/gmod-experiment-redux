local PLUGIN = PLUGIN
local ITEM = ITEM
ITEM.name = "Cleaning Brush"
ITEM.price = 50
ITEM.shipmentSize = 5
ITEM.noBusiness = true
ITEM.model = "models/props_c17/pushbroom.mdl"
ITEM.width = 1
ITEM.height = 3
ITEM.category = "Art"
ITEM.description = "A sturdy cleaning brush used to remove graffiti and other artwork from surfaces. Single use item."

function ITEM:OnEntityCreated(entity)
	entity:SetModel("models/props_c17/suitcase_passenger_physics.mdl")
	entity:PhysicsInit(SOLID_VPHYSICS)
end

local REMOVAL_CHANCE = 0.3

-- Failure messages for when cleaning doesn't work
local failureMessages = {
	"The graffiti is really stuck on there, you didn't manage to get it off",
	"This artwork is more stubborn than expected - your brush couldn't remove it",
	"The paint has dried too well, your cleaning attempt failed",
	"Despite your best efforts, the graffiti remains firmly in place",
	"The surface is too rough - you couldn't scrub the graffiti off",
	"Your brush seems ineffective against this particular artwork",
	"The graffiti laughs at your feeble cleaning attempt"
}

ITEM.functions.Clean = {
	name = "Clean Graffiti",
	tip = "Remove only the graffiti you're directly looking at.",
	icon = "icon16/water.png",
	OnRun = function(item)
		if (SERVER) then
			local player = item.player
			local trace = player:GetEyeTrace()
			local entities = ents.FindInSphere(trace.HitPos, 50)
			local closestGraffiti = nil
			local closestDistance = math.huge

			for _, entity in ipairs(entities) do
				if (IsValid(entity) and entity:GetClass() == "exp_world_canvas_viewer") then
					local distance = entity:GetPos():Distance(trace.HitPos)
					if (distance < closestDistance) then
						closestDistance = distance
						closestGraffiti = entity
					end
				end
			end

			if (closestGraffiti) then
				if (math.random() <= REMOVAL_CHANCE) then
					closestGraffiti:Remove()
					player:Notify("Cleaned nearby graffiti!")
					return true
				else
					-- Pick a random failure message
					local failureMsg = failureMessages[math.random(1, #failureMessages)]
					player:Notify(failureMsg)

					return false
				end
			else
				player:Notify("No graffiti found to clean. Aim closer to the artwork.")
				return false
			end
		end

		return false
	end,
	OnCanRun = function(item)
		return item.player:GetCharacter() and
			item.invID == item.player:GetCharacter():GetInventory():GetID()
	end
}
