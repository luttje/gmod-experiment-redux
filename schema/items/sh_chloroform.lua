local ITEM = ITEM

ITEM.name = "Chloroform"
ITEM.price = 800
ITEM.model = "models/props_junk/garbage_newspaper001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Applying this on somebody will knock them out cold."

ITEM.functions.Apply = {
	OnRun = function(itemTable)
		local chloroformTime = 5
		local client = itemTable.player
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

		itemTable.bBeingUsed = true

		client:SetAction("@chloroforming", chloroformTime)

		target:SetNetVar("beingChloroformed", true)
		target:SetAction("@fBeingChloroformed", chloroformTime)

		client:DoStaredAction(target, function()
			Schema.ChloroformPlayer(target)

			itemTable:Remove()

			hook.Run("OnPlayerBecameChloroformed", target, client)
		end, chloroformTime, function()
			client:SetAction()

			target:SetAction()
			target:SetNetVar("beingChloroformed")

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
