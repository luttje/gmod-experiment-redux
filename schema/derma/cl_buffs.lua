local PANEL = {}

AccessorFunc(PANEL, "padding", "Padding", FORCE_NUMBER)

function PANEL:Init()
	self:SetWide(ScrW() * 0.35)
	self:SetPos(0, 0)
	self:SetBorder(4)
	self:SetSpaceY(8)
	self:SetSpaceX(8)
	self:SetStretchWidth(false)
	self:SetStretchHeight(true)

	self.buffs = {}
	self.padding = 2

	self:RefreshBuffs()
end

function PANEL:GetAll()
	return self.buffs
end

function PANEL:Clear()
	self.buffs = {}

	for _, panel in ipairs(self:GetChildren()) do
		panel:Remove()
	end
end

function PANEL:RefreshBuffs()
	local buffs = Schema.buff.localActiveUntil

	self:Clear()

	local buffAmount = 0

	for index, activeUntil in pairs(buffs) do
		local active = activeUntil > CurTime()

		if (active) then
			self:AddBuff(index, activeUntil)
			buffAmount = buffAmount + 1
		else
			self:RemoveBuff(index)
		end
	end

	if (not self:IsHUDPanel() and buffAmount == 0) then
		local label = self:Add("DLabel")
		label:SetContentAlignment(5)
		label:SetFont("ixSmallFont")
		label:SetTextColor(color_white)
		label:SetText(L("noBuffs"))
		label:SizeToContents()
	end

	self:InvalidateLayout(true)
end

function PANEL:AddBuff(index, activeUntil)
	local panel = self:Add("expBuffIcon")
	panel:SetVisible(true)
	panel:SetBuff(index)
	panel:SetActiveUntil(activeUntil)

	self.buffs[#self.buffs + 1] = panel
	self:Sort()

	return panel
end

function PANEL:RemoveBuff(index)
	for k, buffPanel in ipairs(self.buffs) do
		if (buffPanel.buff.index == index) then
			buffPanel:Remove()

			table.remove(self.buffs, k)
			break
		end
	end

	self:Sort()
end

-- Sort buffs by duration remaining
function PANEL:Sort()
	table.sort(self.buffs, function(a, b)
		return a:GetActiveUntil() > b:GetActiveUntil()
	end)
end

function PANEL:IsHUDPanel()
	return self == ix.gui.buffs
end

function PANEL:Think()
	if (not self:IsHUDPanel()) then
		return
	end

	-- Don't update buffs when not visible and we're not in the character menu
	local menu = (IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing()) and ix.gui.characterMenu
		or IsValid(ix.gui.menu) and ix.gui.menu

	if (menu) then
		local fraction = menu and 1 - menu.currentAlpha / 255 or 1

		self:SetAlpha(255 * fraction)

		if (fraction == 0) then
			return
		end
	end

	local barManager = ix.gui.bars
	local offsetY = 0

	if (IsValid(ix.gui.bars)) then
		offsetY = barManager:GetTall() + barManager:GetPadding()
	end

	self:SetPos(0, offsetY)
end

function PANEL:OnRemove()
	self:Clear()
end

vgui.Register("expBuffManager", PANEL, "DIconLayout")

PANEL = {}

AccessorFunc(PANEL, "expActiveUntil", "ActiveUntil")

function PANEL:Init()
	self.icon = self:Add("expDynamicIcon")
	self.icon:SetSize(48, 48)
	self.icon:Dock(TOP)

	self.label = self:Add("DLabel")
	self.label:Dock(TOP)
	self.label:SetContentAlignment(5)
	self.label:SetFont("expSmallOutlinedFont")
	self.label:SetTextColor(color_white)
	self.label:SetExpensiveShadow(1, color_black)
	self.label:SetText("")

	self:SetSize(48, 48 + 16)
end

function PANEL:SetBuff(buffID)
	self.buff = Schema.buff.Get(buffID)

	local panels = { self, self.label, self.icon }

	for _, panel in ipairs(panels) do
		panel:SetHelixTooltip(function(tooltip)
			Schema.buff.PopulateTooltip(tooltip, self.buff)
		end)
	end

	local opacity = 255

	self.icon:SetBack(self.buff.backgroundImage, self.buff.backgroundColor, opacity)
	self.icon:SetSymbol(self.buff.foregroundImage, opacity)
end

function PANEL:Think()
	local duration = self:GetActiveUntil() - CurTime()

	if (duration <= 0) then
		Schema.buff.localActiveUntil[self.buff.index] = nil
		return
	end

	if (duration < 10) then
		self.icon.opacity = 100 + (155 * math.abs(math.sin(RealTime() * 2)))
	end

	local text = Schema.util.GetNiceShortTime(duration)
	self.label:SetTextColor(Color(255, 255, 255, self.icon.opacity))

	if (text ~= self.label:GetText()) then
		self.label:SetText(text)
		self.label:SizeToContents()
	end
end

vgui.Register("expBuffIcon", PANEL, "EditablePanel")

if (IsValid(ix.gui.buffs)) then
	Schema.buff.CreateHUDPanel()
end
