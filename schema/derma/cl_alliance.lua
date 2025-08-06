local rowPaintFunctions = {
	function(width, height)
	end,

	function(width, height)
		surface.SetDrawColor(30, 30, 30, 25)
		surface.DrawRect(0, 0, width, height)
	end
}

local BUTTON_FONT = "ixMenuButtonFont"
local BUTTON_FONT_SMALL = "ixGenericFont"
local BUTTON_HEIGHT = 32

-- exp_AllianceNotice
local PANEL = {}

function PANEL:Init()
	self:SetTall(BUTTON_HEIGHT)
	self:DockMargin(0, 0, 0, 4)

	self.message = self:Add("DLabel")
	self.message:DockMargin(8, 8, 8, 8)
	self.message:Dock(FILL)
	self.message:SetTextColor(color_white)
	self.message:SetFont(BUTTON_FONT_SMALL)

	self.actions = self:Add("EditablePanel")
	self.actions:Dock(RIGHT)
end

function PANEL:SetMessage(message, actions, noticeKey)
	self.message:SetText(message)
	self.message:SizeToContents()

	local actionsWidth = 0

	if (type(actions) == "table") then
		for i = #actions, 1, -1 do
			local action = actions[i]
			local button = self.actions:Add("expButton")

			button:Dock(RIGHT)
			button:DockMargin(0, 0, 4, 0)
			button:SetScale("small")
			button:SetText(action.text)
			button.DoClick = action.callback

			actionsWidth = actionsWidth + 4 + button:GetWide()
		end
	else
		self.actions:Clear()
	end

	self.close = self.actions:Add("DImageButton")
	self.close:SetSize(16, 16)
	self.close:SetStretchToFit(false)
	self.close:Dock(RIGHT)
	self.close:DockMargin(4, 0, 0, 0)
	self.close:SetImage("icon16/cross.png")
	self.close.DoClick = function()
		self:Remove()
		table.remove(Schema.alliance.notices, noticeKey)
		self:GetParent():Update()
	end
	self.close:SetVisible(true)
	self.close:MoveToBack()

	actionsWidth = actionsWidth + 4 + self.close:GetWide()

	self.actions:SetWide(actionsWidth)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(derma.GetColor("DarkerBackground", self))
	surface.DrawRect(0, 0, width, height)
end

vgui.Register("exp_AllianceNotice", PANEL, "EditablePanel")

-- exp_AllianceNotices
PANEL = {}

function PANEL:Init()
	self.notices = {}
end

function PANEL:AddNotice(message, actions, noticeKey)
	actions = actions == nil and true or actions

	local panel = self:Add("exp_AllianceNotice")
	panel:Dock(TOP)
	panel:SetMessage(message, actions, noticeKey)

	return table.insert(self.notices, panel), panel
end

function PANEL:RemoveNotice(index)
	local panel = self.notices[index]

	if (IsValid(panel)) then
		panel:Remove()
	end

	table.remove(self.notices, index)
end

function PANEL:Update()
	self:Clear()

	local totalHeight = 0

	for noticeKey, notice in ipairs(Schema.alliance.notices) do
		local index, panel = self:AddNotice(notice.notice, notice.actions, noticeKey)

		totalHeight = totalHeight + 4 + panel:GetTall()
	end

	self:SetTall(totalHeight)
end

vgui.Register("exp_AllianceNotices", PANEL, "EditablePanel")

-- exp_AllianceActions
PANEL = {}

function PANEL:Init()
	self:SetTall(64)

	self.inAlliance = self:Add("EditablePanel")
	self.inAlliance:Dock(FILL)

	self.invite = self.inAlliance:Add("expButton")
	self.invite:Dock(LEFT)
	self.invite:SetText("Invite")
	self.invite.DoClick = function()
		local menu = DermaMenu()

		local option = menu:AddOption("Invite the character you are looking at", function()
			ix.command.Send("AllianceInvite")
		end)
		option:SetFont("ixMenuButtonFont")

		-- option = menu:AddOption("Invite character by name", function()
		--     -- TODO
		-- end)
		-- option:SetFont("ixMenuButtonFont")

		menu:Open()
	end

	self.leave = self.inAlliance:Add("expButton")
	self.leave:Dock(RIGHT)
	self.leave:SetText("Leave Alliance")
	self.leave.DoClick = function()
		Derma_Query(
			"Are you sure that you want to leave the alliance?",
			"Leave the alliance.",
			"Yes", function()
				ix.command.Send("AllianceLeave")
			end,
			"No", function() end
		)
	end

	self.notInAlliance = self:Add("EditablePanel")
	self.notInAlliance:Dock(FILL)

	self.create = self.notInAlliance:Add("expButton")
	self.create:Dock(RIGHT)
	self.create:SetText("Create New Alliance (" .. ix.currency.Get(ix.config.Get("allianceCost")) .. ")")
	self.create.DoClick = function()
		Derma_StringRequest(
			"Create New Alliance (" .. ix.currency.Get(ix.config.Get("allianceCost")) .. ")",
			"Enter the name of the alliance you want to create.",
			"",
			function(name)
				ix.command.Send("AllianceCreate", name)
			end
		)
	end
end

function PANEL:SetAlliance(alliance)
	self.alliance = alliance

	if (alliance) then
		self.inAlliance:SetVisible(true)
		self.notInAlliance:SetVisible(false)
	else
		self.inAlliance:SetVisible(false)
		self.notInAlliance:SetVisible(true)
	end
end

vgui.Register("exp_AllianceActions", PANEL, "EditablePanel")

-- exp_AllianceRank
PANEL = {}

function PANEL:Init()
	self:SetFont("ixSmallBoldFont")
	self:SetSize(250, BUTTON_HEIGHT)
	self:DockMargin(0, 0, 4, 0)
end

function PANEL:SetAllianceRank(rank)
	self.rank = rank

	self:SetText(RANKS[rank])

	self:SetTextColor(derma.GetColor("Warning", self))
	self:SizeToContents()
end

vgui.Register("exp_AllianceRank", PANEL, "DLabel")

-- exp_AllianceMember
PANEL = {}

function PANEL:Init()
	self:SetTall(BUTTON_HEIGHT)
	self:DockMargin(0, 0, 0, 4)

	self.rank = self:Add("exp_AllianceRank")
	self.rank:DockMargin(8, 8, 8, 8)
	self.rank:Dock(LEFT)
	self.rank:SetTextColor(color_white)

	self.name = self:Add("DLabel")
	self.name:DockMargin(8, 8, 8, 8)
	self.name:Dock(FILL)
	self.name:SetTextColor(color_white)
	self.name:SetFont("ixSmallBoldFont")

	self.rankButton = self:Add("DImageButton")
	self.rankButton:SetSize(32, 32)
	self.rankButton:SetStretchToFit(false)
	self.rankButton:Dock(RIGHT)
	self.rankButton:SetZPos(1)
	self.rankButton:SetHelixTooltip(function(tooltip)
		local name = tooltip:AddRow("name")
		name:SetText("Set member rank")
		name:SizeToContents()
	end)
	self.rankButton:SetImage("icon16/user_edit.png")
	self.rankButton.DoClick = function()
		local menu = DermaMenu()

		for rank, rankName in ipairs(RANKS) do
			local option = menu:AddOption(rankName, function()
				net.Start("AllianceRequestSetRank")
				net.WriteEntity(self.client)
				net.WriteUInt(rank, 8)
				net.SendToServer()
			end)
			option:SetFont("ixMenuButtonFont")
		end

		menu:Open()
	end

	self.kickButton = self:Add("DImageButton")
	self.kickButton:SetSize(32, 32)
	self.kickButton:SetStretchToFit(false)
	self.kickButton:Dock(RIGHT)
	self.kickButton:SetZPos(0)
	self.kickButton:SetHelixTooltip(function(tooltip)
		local name = tooltip:AddRow("name")
		name:SetText("Kick member")
		name:SizeToContents()
	end)
	self.kickButton:SetImage("icon16/user_delete.png")
	self.kickButton.DoClick = function()
		Derma_Query(
			"Are you sure that you want to kick this member?",
			"Kick member",
			"Yes", function()
				net.Start("AllianceRequestKick")
				net.WriteEntity(self.client)
				net.SendToServer()
			end,
			"No", function() end
		)
	end
end

function PANEL:SetMember(member)
	self.member = member

	local client

	for _, otherClient in ipairs(player.GetAll()) do
		if (not otherClient:GetCharacter()) then
			continue
		end

		if (otherClient:GetCharacter():GetID() == member.id) then
			client = otherClient
			break
		end
	end

	if (IsValid(client)) then
		self.client = client
	end

	if (client == LocalPlayer()) then
		self.kickButton:SetVisible(false)
	end

	self:Update()
end

function PANEL:Update()
	if (not self.member) then
		return
	end

	self.name:SetText(self.member.name)
	self.name:SizeToContents()

	self.rank:SetAllianceRank(self.member.rank)
end

function PANEL:SetBackgroundPaintFunction(func)
	self.paintFunction = func
end

function PANEL:Paint(width, height)
	if (self.paintFunction) then
		self.paintFunction(width, height)
	end
end

vgui.Register("exp_AllianceMember", PANEL, "EditablePanel")

-- exp_AllianceMembers
PANEL = {}

function PANEL:Init()
	self:Update()
end

function PANEL:Update()
	self:Clear()

	self.loading = self:Add("EditablePanel")
	self.loading:Dock(FILL)
	self.loading.Paint = function(self, width, height)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(Material("icon16/hourglass.png"))
		surface.DrawTexturedRectRotated(16, height * .5, 16, 16, RealTime() * 180)
	end

	if (not self.alliance) then
		return
	end

	-- Fetch the alliance members from the server.
	net.Start("AllianceRequestUpdateMembers")
	net.SendToServer()
end

function PANEL:SetMembers(members)
	self:Clear()

	self.members = {}

	for _, member in ipairs(members) do
		local index, memberPanel = self:AddMember(member)
		local id = index % 2 == 0 and 1 or 2

		memberPanel:SetBackgroundPaintFunction(rowPaintFunctions[id])
	end
end

net.Receive("AllianceUpdateMembers", function()
	local members = net.ReadTable()
	local panel = ix.gui.alliance

	if (not IsValid(panel)) then
		return
	end

	panel.members:SetMembers(members)
end)

net.Receive("AllianceRequestUpdateMembersDeclined", function()
	local panel = ix.gui.alliance

	if (not IsValid(panel)) then
		return
	end

	timer.Simple(2.5, function()
		if (not IsValid(panel)) then
			return
		end

		panel.members:Update()
	end)
end)

function PANEL:SetAlliance(alliance)
	if (self.alliance == alliance) then
		return
	end

	self.alliance = alliance

	self:Update()
end

function PANEL:AddMember(member)
	local panel = self:Add("exp_AllianceMember")
	panel:SetMember(member)
	panel:Dock(TOP)

	return table.insert(self.members, panel), panel
end

vgui.Register("exp_AllianceMembers", PANEL, "DScrollPanel")

-- exp_Alliance
PANEL = {}

function PANEL:Init()
	self:Dock(FILL)

	self.title = self:Add("DLabel")
	self.title:DockMargin(0, 0, 0, 8)
	self.title:Dock(TOP)
	self.title:SetFont("ixBigFont")
	self.title:SetText("")

	self.notices = self:Add("exp_AllianceNotices")
	self.notices:DockMargin(0, 0, 0, 8)
	self.notices:Dock(TOP)

	self.actions = self:Add("exp_AllianceActions")
	self.actions:DockMargin(0, 0, 0, 8)
	self.actions:Dock(BOTTOM)

	self.membersHeading = self:Add("DLabel")
	self.membersHeading:DockMargin(0, 0, 0, 8)
	self.membersHeading:Dock(TOP)
	self.membersHeading:SetTextColor(color_white)
	self.membersHeading:SetFont("ixMediumFont")
	self.membersHeading:SetText("")

	self.members = self:Add("exp_AllianceMembers")
	self.members:Dock(FILL)

	self.nextThink = 0

	self:Update()

	ix.gui.alliance = self
end

function PANEL:Update(alliance)
	if (alliance == false) then
		alliance = nil

		Schema.alliance.notices = {}
	else
		alliance = LocalPlayer():GetAlliance()
	end

	self.notices:Update()

	if (not alliance) then
		self.members:SetAlliance(nil)
		self.membersHeading:SetText("You are not in an alliance.")
		self.members:SetVisible(false)
		self.actions:SetAlliance(nil)
		self.title:SetVisible(false)

		return
	end

	self.title:SetVisible(true)
	self.title:SetText("Alliance: '" .. alliance.name .. "'")
	self.title:SetTextColor(derma.GetColor("Success", self))
	self.title:SizeToContents()
	self.actions:SetAlliance(alliance)
	self.members:SetAlliance(alliance)
	self.membersHeading:SetText("Members")
	self.membersHeading:SizeToContents()
	self.members:SetVisible(true)
end

vgui.Register("exp_Alliance", PANEL, "EditablePanel")

hook.Add("CreateMenuButtons", "expAddAllianceMenuButton", function(tabs)
	tabs["alliance"] = function(container)
		container:Add("exp_Alliance")
	end
end)

net.Receive("AllianceForceUpdate", function()
	local panel = ix.gui.alliance

	if (IsValid(panel)) then
		panel:Update()
	end
end)

net.Receive("AllianceMemberLeft", function()
	local memberCharacterId = net.ReadUInt(32)
	local memberName = net.ReadString()
	local leftVoluntarily = net.ReadBool()
	local panel = ix.gui.alliance

	if (not IsValid(panel)) then
		return
	end

	local character = LocalPlayer():GetCharacter()

	if (memberCharacterId == character:GetID()) then
		panel:Update(false)
	else
		panel:Update()
	end
end)
