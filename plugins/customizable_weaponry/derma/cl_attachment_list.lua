local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
	if (IsValid(ix.gui.expAttachmentList)) then
		ix.gui.expAttachmentList:Remove()
	end

	self:SetTitle("Attachment Compatibility List")
	self:SetSize(460, 360)
	self:Center()
	self:MakePopup()

	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)

	ix.gui.expAttachmentList = self
end

function PANEL:AddCompatibleWeapon(itemTable)
	local weapon = weapons.Get(itemTable.class)

	if (not weapon) then
		return
	end

	local panel = self.list:Add("DPanel")
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 0, 5)
	panel:SetTall(64)

	local icon = panel:Add("SpawnIcon")
	icon:Dock(LEFT)
	icon:SetSize(64, 64)
	icon:InvalidateLayout(true)
	icon:SetModel(itemTable:GetModel(), itemTable:GetSkin())
	icon:SetHelixTooltip(function(tooltip)
		ix.hud.PopulateItemTooltip(tooltip, itemTable)
	end)
	icon.itemTable = itemTable

	local label = panel:Add("DLabel")
	label:Dock(FILL)
	label:DockMargin(5, 0, 0, 0)
	label:SetFont("ixMediumFont")
	label:SetText(weapon.PrintName)
	label:SetContentAlignment(4)
	label:SetExpensiveShadow(1, Color(0, 0, 0, 150))
end

function PANEL:Populate(attachmentId)
	local compatibleItems = PLUGIN:GetCompatibleItems(attachmentId)
	local attachment = TacRP.GetAttTable(attachmentId)

	table.SortByMember(compatibleItems, "name", true)

	self:SetTitle("Weapons compatible with the '" .. attachment.PrintName .. "'")

	for _, weaponItem in ipairs(compatibleItems) do
		self:AddCompatibleWeapon(weaponItem)
	end
end

vgui.Register("expAttachmentList", PANEL, "DFrame")
