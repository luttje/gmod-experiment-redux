local ITEM = ITEM

ITEM.name = "Chloroform"
ITEM.price = 450
ITEM.model = "models/props_junk/garbage_newspaper001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Applying this on somebody will knock them out cold."

ITEM.functions.Apply = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local baseTaskTime = 15
		local taskTime = Schema.GetDexterityTime(client, baseTaskTime)
		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 70
        data.filter = client

		local target = util.TraceLine(data).Entity
		local isTargetValid = IsValid(target) and target:IsPlayer() and target:GetCharacter()

		if (not isTargetValid) then
			itemTable.player:NotifyLocalized("plyNotValid")
			return false
		end

		local canPerform = hook.Run("CanPlayerChloroform", client, target)

		if (canPerform == false) then
			return false
		end

		taskTime = math.Clamp(taskTime, 2, baseTaskTime)

		itemTable.bBeingUsed = true

		client:SetNetVar("chloroforming", true)
		client:SetAction("@chloroforming", taskTime)

		target:SetNetVar("beingChloroformed", true)
		target:SetAction("@fBeingChloroformed", taskTime)

		client:DoStaredAction(target, function()
			client:SetNetVar("chloroforming")
			Schema.ChloroformPlayer(target)

			itemTable:Remove()

			Schema.PlayerClearEntityInfoTooltip(client)
			hook.Run("OnPlayerBecameChloroformed", target, client)
		end, taskTime, function()
			if (IsValid(client)) then
				client:SetAction()
				client:SetNetVar("chloroforming")
				Schema.PlayerClearEntityInfoTooltip(client)
			end

			if (IsValid(target)) then
				target:SetAction()
				target:SetNetVar("beingChloroformed")
			end

			itemTable.bBeingUsed = false
		end)

		return false
	end,

	OnCanRun = function(item)
        local client = item.player

        -- Ensure it's in the player's inventory
        if (not client or item.invID ~= client:GetCharacter():GetInventory():GetID()) then
            return false
        end

		return not item.bBeingUsed
	end
}

function ITEM:CanTransfer(inventory, newInventory)
	return not self.bBeingUsed
end
