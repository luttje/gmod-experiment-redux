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

ITEM.functions.destroy = {
	name = "Destroy",
	tip = "Destroy the item.",
	icon = "icon16/cross.png",
	OnRun = function(item)
		item.player:Notify("You have destroyed the item.")
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
