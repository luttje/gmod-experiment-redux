local ITEM = ITEM

ITEM.name = "Zip Tie"
ITEM.price = 150
ITEM.model = "models/items/crossbowrounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "An orange zip tie with Thomas and Betts printed on the side."

ITEM.functions.Tie = {
	-- Note that we always return false, because we manually remove the zip tie when not cancelling the action.
	OnRun = function(itemTable)
		local client = itemTable.player
		local hasQuickHands, quickHandsPerkTable = Schema.perk.GetOwned("quick_hands", client)
		local baseTaskTime = 10
		local taskTime = Schema.GetDexterityTime(client, baseTaskTime)

		if (hasQuickHands) then
			taskTime = taskTime * quickHandsPerkTable.tieTimeMultiplier
		end

		taskTime = math.Clamp(taskTime, 2, baseTaskTime)

		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 70
		data.filter = client

		local target = util.TraceLine(data).Entity
		local lookTarget = target

		if (IsValid(target:GetNetVar("player"))) then
			target = target:GetNetVar("player")
		end

		local isTargetValid = IsValid(target) and target:IsPlayer() and target:GetCharacter()
			and not target:GetNetVar("beingTied") and not target:IsRestricted()
		-- target:GetNetVar("tied", false)

		if (not isTargetValid) then
			itemTable.player:NotifyLocalized("plyNotValid")
			return false
		end

		local canPerform = hook.Run("CanPlayerTie", client, target)

		if (canPerform == false) then
			return false
		end

		itemTable.bBeingUsed = true

		client:SetNetVar("tying", true)
		client:SetAction("@tying", taskTime)

		target:SetNetVar("beingTied", true)
		target:SetAction("@fBeingTied", taskTime)

        client:DoStaredAction(lookTarget, function()
            client:SetNetVar("tying")
			Schema.TiePlayer(target)

			Schema.achievement.Progress("zip_ninja", client)
            Schema.PlayerClearEntityInfoTooltip(client)

			itemTable:Remove()

			hook.Run("OnPlayerBecameTied", target, client)
        end, taskTime, function()
			if (IsValid(client)) then
				client:SetAction()
				client:SetNetVar("tying")
				Schema.PlayerClearEntityInfoTooltip(client)
			end

			if (IsValid(target)) then
				target:SetAction()
				target:SetNetVar("beingTied")
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
