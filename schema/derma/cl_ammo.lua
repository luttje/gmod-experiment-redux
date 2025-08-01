local PANEL = {}

AccessorFunc(PANEL, "padding", "Padding", FORCE_NUMBER)

function PANEL:Init()
	self:SetWide(ScrW() * 0.25)
	self:SetPos(ScrW() - self:GetWide(), 0)
	self:SetBorder(4)
	self:SetSpaceY(4)
	self:SetSpaceX(4)
	self:SetStretchWidth(false)
	self:SetStretchHeight(true)

	self.padding = 2
	self.ammoIcons = {}
	self.ammoLookup = {}

	self:RefreshAmmo()
end

function PANEL:GetAll()
	return self.ammoIcons
end

function PANEL:Clear()
	self.ammoIcons = {}
	self.ammoLookup = {}

	for _, panel in ipairs(self:GetChildren()) do
		panel:Remove()
	end
end

function PANEL:RefreshAmmo()
	if (not IsValid(LocalPlayer())) then
		return
	end

	local playerAmmo = LocalPlayer():GetAmmo()

	self:Clear()

	local ammoCount = 0

	for ammoID, amount in pairs(playerAmmo) do
		if amount > 0 then
			self:AddAmmo(ammoID, amount)
			ammoCount = ammoCount + 1
		end
	end

	if ammoCount == 0 then
		local label = self:Add("DLabel")
		label:SetContentAlignment(5)
		label:SetFont("ixSmallFont")
		label:SetTextColor(color_white)
		label:SetText("None")
		label:SizeToContents()
	end

	self:InvalidateLayout(true)
end

function PANEL:AddAmmo(ammoID, amount)
	local panel = self:Add("expAmmoIcon")
	panel:SetVisible(true)
	panel:SetAmmo(ammoID, amount)

	self.ammoIcons[#self.ammoIcons + 1] = panel
	self.ammoLookup[ammoID] = panel

	return panel
end

local needsAmmoUpdate = nil

function PANEL:Think()
	-- Refresh ammo if it changed
	if (needsAmmoUpdate) then
		needsAmmoUpdate = nil
		self:RefreshAmmo()
	end
end

function PANEL:OnRemove()
	self:Clear()
end

vgui.Register("expAmmoManager", PANEL, "DIconLayout")

hook.Add("PlayerAmmoChanged", "expAmmoManagerRefresh", function()
	if (IsValid(LocalPlayer())) then
		needsAmmoUpdate = true
	end
end)

-- Ammo Icon Panel
PANEL = {}

AccessorFunc(PANEL, "ammoID", "AmmoID", FORCE_NUMBER)
AccessorFunc(PANEL, "ammoAmount", "AmmoAmount", FORCE_NUMBER)

function PANEL:Init()
	self.spawnIcon = self:Add("SpawnIcon")
	self.spawnIcon:SetSize(48, 48)
	self.spawnIcon:Dock(FILL)
	self.spawnIcon.DoClick = function()
		local menu = DermaMenu()
		menu:AddOption(L "unequip", function()
			net.Start("expAmmoUnequip")
			net.WriteUInt(self:GetAmmoID(), 32)
			net.WriteBool(false) -- don't drop
			net.SendToServer()
		end):SetImage("icon16/cross.png")
		menu:AddOption(L "drop", function()
			net.Start("expAmmoUnequip")
			net.WriteUInt(self:GetAmmoID(), 32)
			net.WriteBool(true) -- drop
			net.SendToServer()
		end):SetImage("icon16/brick.png")
		menu:Open()
	end

	self.label = self:Add("DLabel")
	self.label:Dock(BOTTOM)
	self.label:SetContentAlignment(5)
	self.label:SetFont("expSmallOutlinedFont")
	self.label:SetTextColor(color_white)
	self.label:SetExpensiveShadow(1, color_black)
	self.label:SetText("0")
	self.label:SizeToContents()

	self:SetSize(52, 52 + self.label:GetTall())
end

function PANEL:SetAmmo(ammoID, amount)
	self:SetAmmoID(ammoID)
	self:SetAmmoAmount(amount)

	local ammoName = game.GetAmmoName(ammoID)
	local relevantItem = Schema.ammo.FindMainAmmoItem(ammoID)

	if not relevantItem then
		ix.util.SchemaErrorNoHaltWithStack("No relevant ammo item found for ammo ID: " ..
			tostring(ammoID) .. " (" .. ammoName .. ")")
		return
	end

	-- Set the model for the SpawnIcon
	if relevantItem.model then
		self.spawnIcon:SetModel(relevantItem.model)
	end

	-- Set tooltip with ammo information
	self.spawnIcon:SetHelixTooltip(function(tooltip)
		local name = tooltip:AddRow("name")
		name:SetImportant()
		name:SetText(relevantItem.name or ammoName)
		name:SizeToContents()

		local amount = tooltip:AddRow("amount")
		amount:SetText("Total Ammo Count: " .. tostring(self:GetAmmoAmount()))
		-- amount:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		amount:SizeToContents()

		tooltip:SizeToContents()
	end)

	-- Update the amount label
	self.label:SetText(tostring(amount))
	self.label:SizeToContents()
end

function PANEL:Think()
	-- Update amount if it changed
	local currentAmount = LocalPlayer():GetAmmo()[self:GetAmmoID()] or 0

	if currentAmount ~= self:GetAmmoAmount() then
		self:SetAmmoAmount(currentAmount)
		self.label:SetText(tostring(currentAmount))
		self.label:SizeToContents()
	end
end

vgui.Register("expAmmoIcon", PANEL, "EditablePanel")
