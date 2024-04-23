local ITEM = ITEM

ITEM.name = "A piece of paper"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Some paper with writing on it."
ITEM.noBusiness = true

function ITEM:OnRead()
	-- Override this function to add custom behavior when reading the item.
end

if (SERVER) then
    util.AddNetworkString("expRead")
end

if (CLIENT) then
    function ITEM:GetText()
        return [[
			There is nothing written on this piece of paper.
		]]
    end

	net.Receive("expRead", function()
		local itemID = net.ReadUInt(32)
		local item = ix.item.instances[itemID]

		if (not item) then
			ErrorNoHalt("Attempted to read a lore item that doesn't exist!\n")
			return
		end

		local frame = vgui.Create("expReadableFrame")
        frame:SetTitle(item:GetName())

        local text, isFullHtml = item:GetText()
        frame:SetText(text, isFullHtml)

        if (item.GetFrameSize) then
            local width, height = item:GetFrameSize()

            frame:SetSize(width, height)
            frame:Center()
        end

        if (item.hideFrameTitleBar) then
            frame:HideTitleBar()
        end

        -- NOTE: Books are expected to handle closing themselves. For this they need
		-- to take full control of the frame with HTML (by returning true as the second
		-- result of ITEM:GetText() and console.log("CLOSE_READABLE") from JavaScript).
        if (item.hideFrameCloseButton) then
            frame:HideCloseButton()
        end

		hook.Run("OnPlayerItemRead", item, frame)
    end)
end

ITEM.functions.Read = {
	name = "Read",
	tip = "Read what's on this piece of paper.",
	icon = "icon16/book_open.png",
	OnRun = function(item)
        local client = item.player

		item.OnRead(item)

		net.Start("expRead")
			net.WriteUInt(item:GetID(), 32)
        net.Send(client)

		return false
	end
}
