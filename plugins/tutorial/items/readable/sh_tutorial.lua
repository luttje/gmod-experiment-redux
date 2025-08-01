local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "An Introduction"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.description = "A piece of paper with drawings on them. They're warnings from the past."
ITEM.noDrop = true
ITEM.hideFrameTitleBar = true
ITEM.hideFrameCloseButton = true

function ITEM:GetText()
	local html = Schema.util.GetHtml("tutorial.html")

	return html, true
end

function ITEM:GetFrameSize()
	return ScrW(), ScrH()
end

if (SERVER) then
	util.AddNetworkString("expConfirmDestroy")
	util.AddNetworkString("expConfirmedDestroy")

	net.Receive("expConfirmedDestroy", function(len, client)
		local itemID = net.ReadUInt(32)
		local item = ix.item.instances[itemID]

		if (not item) then
			ix.util.SchemaErrorNoHalt("Attempted to destroy a lore item that doesn't exist!\n")
			return
		end

		local inventory = client:GetCharacter():GetInventory()
		inventory:Remove(itemID)

		client:Notify("You have destroyed the item.")
	end)
end

if (CLIENT) then
	net.Receive("expConfirmDestroy", function()
		local itemID = net.ReadUInt(32)
		local item = ix.item.instances[itemID]

		if (not item) then
			ix.util.SchemaErrorNoHalt("Attempted to destroy a lore item that doesn't exist!\n")
			return
		end

		Derma_Query(
			"Are you sure you want to destroy this item? You will not be able to read it again.",
			"Confirm Destroy Item",
			L("yes"),
			function()
				net.Start("expConfirmedDestroy")
				net.WriteUInt(itemID, 32)
				net.SendToServer()
			end,
			L("no")
		)
	end)
end

ITEM.functions.destroy = {
	name = "Destroy",
	tip = "Destroy the item.",
	icon = "icon16/cross.png",
	OnRun = function(item)
		local client = item.player

		net.Start("expConfirmDestroy")
		net.WriteUInt(item:GetID(), 32)
		net.Send(client)

		return false -- Prevents the item from being removed immediately
	end,
	OnCanRun = function(item)
		if (CLIENT) then
			return true
		end

		local character = item.player:GetCharacter()
		local timeStamp = math.floor(os.time())

		-- Ensure their character has been created for at least 5 minutes.
		if (character:GetCreateTime() + (60 * 5) > timeStamp) then
			item.player:Notify("You should read this, it's important. You can destroy it in a few minutes.")
			return false
		end

		return true
	end
}
