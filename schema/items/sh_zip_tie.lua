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
		local tyingTime = 5

		if (hasQuickHands) then
			tyingTime = tyingTime * quickHandsPerkTable.tieTimeMultiplier
		end

		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 70
		data.filter = client

		local target = util.TraceLine(data).Entity
		local isTargetValid = IsValid(target) and target:IsPlayer() and target:GetCharacter()
			and not target:GetNetVar("tying") and not target:IsRestricted()

		if (not isTargetValid) then
			itemTable.player:NotifyLocalized("plyNotValid")
			return false
		end

		itemTable.bBeingUsed = true

		client:SetAction("@tying", tyingTime)

		target:SetNetVar("tying", true)
		target:SetAction("@fBeingTied", tyingTime)

		client:DoStaredAction(target, function()
			Schema.TiePlayer(target)

			if (IsValid(client)) then
				Schema.achievement.Progress(client, "zip_ninja")
				Schema.PlayerClearEntityInfoTooltip(client)
			end

			itemTable:Remove()
		end, tyingTime, function()
			client:SetAction()

			target:SetAction()
			target:SetNetVar("tying")

			Schema.PlayerClearEntityInfoTooltip(client)
			itemTable.bBeingUsed = false
		end)

		return false
	end,

	OnCanRun = function(itemTable)
		return ! IsValid(itemTable.entity) or itemTable.bBeingUsed
	end
}

function ITEM:CanTransfer(inventory, newInventory)
	return ! self.bBeingUsed
end
