local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Design Canvas"
ITEM.price = 25
ITEM.shipmentSize = 10
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Art"
ITEM.description =
"A blank canvas for creating custom logos and drawings. Use it to design artwork that can be shared with other players."

function ITEM:GetName()
	return self:GetData("design", {}).name or (CLIENT and L(self.name) or self.name)
end

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local designData = self:GetData("design")

		if (designData) then
			local panel = tooltip:AddRowAfter("name", "design_status")
			panel:SetBackgroundColor(PLUGIN.THEME.success)
			panel:SetText("Contains Custom Design")
			panel:SizeToContents()
		else
			local panel = tooltip:AddRowAfter("name", "design_status")
			panel:SetBackgroundColor(PLUGIN.THEME.warning)
			panel:SetText("Blank Canvas")
			panel:SizeToContents()
		end
	end
end

-- The A here is to order at the top of the menu
ITEM.functions.AEdit = {
	name = "Edit Canvas",
	tip = "Open the canvas designer to create artwork.",
	icon = "icon16/palette.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("expCanvasDesigner")
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		return item.player:GetCharacter() and item.invID == item.player:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.Copy = {
	name = "Copy Other Canvas",
	tip = "Copies the design from another canvas.",
	icon = "icon16/page_copy.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("expCanvasCopySelector")
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		return item.player:GetCharacter() and item.invID == item.player:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.View = {
	name = "View Design",
	tip = "View the artwork on this canvas.",
	icon = "icon16/zoom.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("expCanvasView")
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		local designData = item:GetData("design")
		return designData
	end
}
