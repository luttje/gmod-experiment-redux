local PANEL = {}

AccessorFunc(PANEL, "padding", "Padding", FORCE_NUMBER)

function PANEL:Init()
	self:SetSize(ScrW() * 0.35, ScrH())
	self:SetPos(4, 4)
	self:ParentToHUD()

	self.buffs = {}
	self.padding = 2

	-- Add buffs that were registered before manager creation
	for uniqueID, activeUntil in ipairs(Schema.buff.localActiveUntil) do
		self:AddBuff(uniqueID, activeUntil)
	end
end

function PANEL:GetAll()
	return self.buffs
end

function PANEL:Clear()
	for k, buffPanel in ipairs(self.buffs) do
		buffPanel:Remove()

		table.remove(self.buffs, k)
	end
end

function PANEL:AddBuff(uniqueID, activeUntil)
	local panel = self:Add("expBuffIcon")
	panel:SetVisible(true)
	panel:SetBuff(uniqueID)
	panel:SetActiveUntil(activeUntil)

	self.buffs[#self.buffs + 1] = panel
	self:Sort()

	return panel
end

function PANEL:RemoveBuff(uniqueID)
	for k, buffPanel in ipairs(self.buffs) do
		if (buffPanel.buff.uniqueID == uniqueID) then
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

function PANEL:Think()
	local menu = (IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing()) and ix.gui.characterMenu
		or IsValid(ix.gui.menu) and ix.gui.menu
	local fraction = menu and 1 - menu.currentAlpha / 255 or 1

	self:SetAlpha(255 * fraction)

	-- Don't update buffs when not visible
	if (fraction == 0) then
		return
	end

	local barManager = ix.gui.bars
	local offsetY = 0

	if (IsValid(ix.gui.bars)) then
		offsetY = barManager:GetTall() + barManager:GetPadding()
	end

	self:SetPos(4, 4 + offsetY)
end

function PANEL:OnRemove()
	self:Clear()
end

vgui.Register("expBuffManager", PANEL, "Panel")

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

	self:SetWide(48)
end

function PANEL:SetBuff(buffID)
	self.buff = Schema.buff.Get(buffID)

	local opacity = 255

	self.icon:SetBack(self.buff.backgroundImage, self.buff.backgroundColor, opacity)
	self.icon:SetSymbol(self.buff.foregroundImage, opacity)
end

function PANEL:Think()
	local duration = self:GetActiveUntil() - CurTime()

	if (duration <= 0) then
		Schema.buff.UpdateOnPanel(self.buff.uniqueID, self:GetActiveUntil())
		return
	end

	if (duration < 10) then
		self.icon.opacity = 100 + (155 * math.abs(math.sin(RealTime() * 2)))
	end

	local text = Schema.util.GetNiceShortTime(duration)
	self.label:SetTextColor(Color(255, 255, 255, self.icon.opacity))
	self.label:SetText(text)
	self.label:SizeToContents()

	self:SetTall(self.icon:GetTall() + self.label:GetTall())
end

function PANEL:PaintOver(width, height)
end

vgui.Register("expBuffIcon", PANEL, "EditablePanel")

if (IsValid(ix.gui.buffs)) then
	ix.gui.buffs:Remove()
	ix.gui.buffs = vgui.Create("expBuffManager")

	if (Schema.buff.localActiveUntil) then
		for uniqueID, activeUntil in pairs(Schema.buff.localActiveUntil) do
			Schema.buff.UpdateOnPanel(uniqueID, activeUntil)
		end
	end
end
