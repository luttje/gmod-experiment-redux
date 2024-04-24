local ITEM = ITEM

ITEM.name = "Bandage"
ITEM.model = "models/props_wasteland/prison_toiletchunk01f.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Medical"
ITEM.description = "A bandage roll, there isn't much so use it wisely."
ITEM.healAmount = 10
ITEM.healSound = nil

ITEM.functions.ApplySelf = {
	name = "Apply To Self",
	tip = "Use this item to heal yourself.",
	icon = "icon16/heart.png",
	OnRun = function(item)
        local client = item.player
		local throttled, remaining = Schema.util.Throttle("allowHeal", 10, client)

		if (throttled) then
			client:Notify("You can't use this for another " .. string.NiceTime(remaining) .. "!")
			return false
		end

		client:SetHealth(
			math.Clamp(client:Health() + Schema.GetHealAmount(client, item.healAmount), 0,
				client:GetMaxHealth())
		)

		if (item.healSound) then
			client:EmitSound(item.healSound, 50, 100, 0.7)
		end

		hook.Run("PlayerHealed", client, client, item)
	end
}

ITEM.functions.ApplyLookAt = {
	name = "Apply To Character",
	tip = "Use this item to heal the person you are looking at.",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local client = item.player
		local throttled, remaining = Schema.util.Throttle("allowHeal", 10, client)

		if (throttled) then
			client:Notify("You can't use this for another " .. string.NiceTime(remaining) .. "!")
			return false
		end

		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity

		if (not IsValid(target) or not target:IsPlayer()) then
			client:Notify("You must be looking at a valid character!")
			return false
		end

		if (not target:Alive()) then
			client:Notify("The player you are looking at is beyond help!")
			return false
		end

		client._NextAllowedHeal = CurTime() + 10

		client:SetHealth(
			math.Clamp(client:Health() + Schema.GetHealAmount(client, item.healAmount), 0,
				client:GetMaxHealth())
		)

		if (item.healSound) then
			client:EmitSound(item.healSound, 50, 100, 0.7)
		end

		hook.Run("PlayerHealed", client, target, item)
	end,

	OnCanRun = function(item)
		local client = item.player
		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity

		return IsValid(target) and target:IsPlayer() and target:GetCharacter()
	end
}
