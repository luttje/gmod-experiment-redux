local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Boxing Bag"
ITEM.price = 250
ITEM.shipmentSize = 3
ITEM.model = "models/experiment-redux/boxing_bag.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.category = "Equipment"
ITEM.description =
"A heavy boxing bag that hangs from the ceiling. Perfect for training strength and stress relief. To use it, you need a pair of boxing gloves."
ITEM.maximum = 3

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		if (not self.maximum) then
			return
		end
		local panel = tooltip:AddRowAfter("name", "maximum")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText("You can only have " .. self.maximum .. " of this item in the world at a time!")
		panel:SizeToContents()
	end
end

if (SERVER) then
	ix.util.AddResourceFile("materials/models/experiment-redux/boxing_bag/Material.vmt")
	ix.util.AddResourceFile("models/experiment-redux/boxing_bag.mdl")
end

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player

		if (client:IsObjectLimited("boxingBags", item.maximum)) then
			client:Notify("You can not place this as you have reached the maximum amount of this item!")
			return false
		end

		local success, message, trace = client:TryTraceInteractAtDistance()
		if (not success) then
			client:Notify(message)
			return false
		end

		-- Check if the surface is roughly horizontal (ceiling-like)
		local normal = trace.HitNormal

		if (normal.z > -0.9) then -- Normal should point downward for a ceiling
			client:Notify("You can only place the boxing bag on a ceiling surface!")
			return false
		end

		-- Calculate where the boxing bag would hang
		local bagPosition = trace.HitPos + Vector(0, 0, -74)

		-- Do a box check to ensure there's room for the boxing bag
		local mins = Vector(-32, -32, -37) -- Half of 64x64x74
		local maxs = Vector(32, 32, 37)

		local boxTrace = util.TraceHull({
			start = bagPosition,
			endpos = bagPosition,
			mins = mins,
			maxs = maxs,
			filter = client
		})

		if (boxTrace.Hit) then
			client:Notify("Not enough space to place the boxing bag here!")
			return false
		end

		-- Create the boxing bag entity
		local entity = ents.Create("exp_boxing_bag")
		entity:SetupBoxingBag(client, trace.HitPos, item)
		entity:SetPos(bagPosition)
		entity:Spawn()

		client:AddLimitedObject("boxingBags", entity)
		client:RegisterEntityToRemoveOnLeave(entity)

		-- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		-- For this reason we manually transfer the item to the world(0)
		item:Transfer(0, nil, nil, nil, false, true)
		return false
	end,

	OnCanRun = function(item)
		local client = item.player

		-- Ensure it's in the player's inventory
		if (not client or item.invID ~= client:GetCharacter():GetInventory():GetID()) then
			return false
		end

		local success, message, trace = client:TryTraceInteractAtDistance()
		if (not success) then
			return false
		end

		-- Check if player already has maximum boxing bags
		local character = client:GetCharacter()
		local boxingBags = character:GetVar("boxingBags") or {}

		if (#boxingBags >= item.maximum) then
			client:Notify("You have reached the maximum amount of boxing bags!")
			return false
		end

		return true
	end
}
