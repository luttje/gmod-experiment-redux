local rowPaintFunctions = {
	function(width, height)
	end,

	function(width, height)
		surface.SetDrawColor(30, 30, 30, 25)
		surface.DrawRect(0, 0, width, height)
	end
}

-- exp_AllianceNotice
local PANEL = {}

function PANEL:Init()
	self:SetTall(32)
	self:DockMargin(0, 0, 0, 4)

	self.message = self:Add("DLabel")
	self.message:DockMargin(8, 8, 8, 8)
	self.message:Dock(FILL)
	self.message:SetTextColor(color_white)
	self.message:SetFont("ixGenericFont")

	self.actions = self:Add("EditablePanel")
	self.actions:Dock(RIGHT)
end

function PANEL:SetMessage(message, actions)
	self.message:SetText(message)
	self.message:SizeToContents()

	if (type(actions) == "table") then
		for _, action in ipairs(actions) do
			local button = self.actions:Add("DButton")
			button:SetFont("ixGenericFont")
			button:SetText(action.text)
			button:SizeToContents()
			button:Dock(RIGHT)
			button:DockMargin(0, 0, 4, 0)
			button.DoClick = action.callback
		end
	elseif (actions == true) then
		self.close = self.actions:Add("DImageButton")
		self.close:SetSize(16, 16)
		self.close:SetStretchToFit(false)
		self.close:Dock(RIGHT)
		self.close:SetImage("icon16/cross.png")
		self.close.DoClick = function()
			self:Remove()
		end
		self.close:SetVisible(true)
	else
		self.actions:Clear()
	end
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

function PANEL:GetNoticesHeight()
	local height = 0

	for _, panel in ipairs(self.notices) do
		if (IsValid(panel)) then
			height = height + panel:GetTall()
		end
	end

	return height
end

function PANEL:PerformLayout(width, height)
	local newHeight = self:GetNoticesHeight()

	if (newHeight ~= height) then
		self:SetTall(newHeight)
		self:GetParent():InvalidateLayout()
	end
end

function PANEL:AddNotice(message, actions)
	actions = actions == nil and true or actions

	local panel = self:Add("exp_AllianceNotice")
	panel:SetMessage(message, actions)
	panel:Dock(TOP)

	return table.insert(self.notices, panel)
end

function PANEL:RemoveNotice(index)
	local panel = self.notices[index]

	if (IsValid(panel)) then
		panel:Remove()
	end

	table.remove(self.notices, index)
end

vgui.Register("exp_AllianceNotices", PANEL, "DScrollPanel")

-- exp_AllianceActions
PANEL = {}

function PANEL:Init()
	self:SetTall(64)

	self.leave = self:Add("DButton")
	self.leave:SetTall(32)
	self.leave:Dock(RIGHT)
	self.leave:SetFont("ixSmallFont")
	self.leave:SetText("Leave Alliance")
	self.leave:SizeToContentsX(32)
	self.leave.DoClick = function()
		Derma_Query(
			"Are you sure that you want to leave the alliance?",
			"Leave the alliance.",
			"Yes", function()
				ix.command.Send("AllyLeave")
			end,
			"No", function() end
		)
	end

	self.create = self:Add("DButton")
	self.create:SetTall(32)
	self.create:Dock(RIGHT)
	self.leave:SetFont("ixSmallFont")
	self.create:SetText("Create New Alliance (".. ix.currency.Get(ix.config.Get("allianceCost")) ..")")
	self.create:SizeToContentsX(32)
	self.create.DoClick = function()
		Derma_StringRequest(
			"Create New Alliance (".. ix.currency.Get(ix.config.Get("allianceCost")) ..")",
			"Enter the name of the alliance you want to create.",
			"",
			function(name)
				net.Start("AllianceRequestCreate")
				net.WriteString(name)
				net.SendToServer()
			end
		)
	end
end

function PANEL:SetAlliance(alliance)
	self.alliance = alliance

	if (alliance) then
		self.leave:SetVisible(true)
		self.create:SetVisible(false)
	else
		self.leave:SetVisible(false)
		self.create:SetVisible(true)
	end
end

vgui.Register("exp_AllianceActions", PANEL, "EditablePanel")

-- exp_AllianceRank
PANEL = {}

function PANEL:Init()
	self:SetSize(250, 32)
	self:DockMargin(0, 0, 4, 0)
end

function PANEL:SetAllianceRank(rank)
	self.rank = rank

	if (rank == RANK_GEN) then
		self:SetText("General")
	elseif (rank == RANK_COL) then
		self:SetText("Colonel")
	elseif (rank == RANK_MAJ) then
		self:SetText("Major")
	elseif (rank == RANK_CPT) then
		self:SetText("Captain")
	elseif (rank == RANK_LT) then
		self:SetText("Lieutenant")
	elseif (rank == RANK_SGT) then
		self:SetText("Sergeant")
	elseif (rank == RANK_PVT) then
		self:SetText("Private")
	else
		self:SetText("")
	end

	self:SetFont("ixSmallFont")
	self:SetTextColor(derma.GetColor("Warning", self))
	self:SizeToContents()
end

vgui.Register("exp_AllianceRank", PANEL, "DLabel")

-- exp_AllianceMember
PANEL = {}

function PANEL:Init()
	self:SetTall(32)
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
	self.paintFunction(width, height)
end

vgui.Register("exp_AllianceMember", PANEL, "EditablePanel")

-- exp_AllianceMembers
PANEL = {}

function PANEL:Init()
	self.members = {}

	self.nextThink = 0
end

function PANEL:Update()
	if (not self.alliance) then
		return
	end

	-- Fetch the alliance members from the server.
	net.Start("AllianceRequestUpdateMembers")
	net.SendToServer()
end

function PANEL:SetMembers(members)
	for _, panel in ipairs(self.members) do
		panel:Remove()
	end

	self.members = {}

	for _, member in ipairs(members) do
		local index = self:AddMember(member)
		local id = index % 2 == 0 and 1 or 2
		local memberPanel = self.members[index]
		memberPanel:SetBackgroundPaintFunction(rowPaintFunctions[id])
	end

	self:SetTall(self:GetMembersHeight())
end

net.Receive("AllianceUpdateMembers", function()
	local members = net.ReadTable()
	local panel = ix.gui.alliance

	if (not IsValid(panel)) then
		return
	end

	panel.members:SetMembers(members)
end)

function PANEL:GetMembersHeight()
	local height = 0

	for _, panel in ipairs(self.members) do
		if (IsValid(panel)) then
			height = height + panel:GetTall()
		end
	end

	return height
end

function PANEL:PerformLayout(width, height)
	local newHeight = self:GetMembersHeight()

	if (newHeight ~= height) then
		self:SetTall(newHeight)
		self:GetParent():InvalidateLayout()
	end
end

function PANEL:SetAlliance(alliance)
	if (self.alliance == alliance) then
		return
	end

	self.alliance = alliance

	for _, panel in ipairs(self.members) do
		panel:Remove()
	end

	if (alliance) then
		self:Update()
	end
end

function PANEL:AddMember(member)
	local panel = self:Add("exp_AllianceMember")
	panel:SetMember(member)
	panel:Dock(TOP)

	return table.insert(self.members, panel)
end

function PANEL:Think()
	if (CurTime() >= self.nextThink) then
		self:Update()
		self.nextThink = CurTime() + 6
	end
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
	self.actions:Dock(TOP)

	self.membersHeading = self:Add("DLabel")
	self.membersHeading:DockMargin(8, 8, 8, 8)
	self.membersHeading:Dock(TOP)
	self.membersHeading:SetTextColor(color_white)
	self.membersHeading:SetFont("ixMediumFont")
	self.membersHeading:SetText("")

	self.members = self:Add("exp_AllianceMembers")
	self.members:Dock(FILL)

	self.nextThink = 0

	ix.gui.alliance = self
end

function PANEL:Update(alliance)
	if (alliance == false) then
		alliance = nil
	else
		alliance = LocalPlayer():GetAlliance()
	end

	if (not alliance) then
		if (not self.noAllianceNotice) then
			self.noAllianceNotice = self.notices:AddNotice("You are not in an alliance.", false)
			self.members:SetAlliance(nil)
			self.membersHeading:SetText("")
			self.actions:SetAlliance(nil)
			self.title:SetVisible(false)
		end

		return
	end

	if (self.noAllianceNotice) then
		self.notices:RemoveNotice(self.noAllianceNotice)
		self.noAllianceNotice = nil
		self.title:SetVisible(true)
	end

	self.actions:SetAlliance(alliance)
	self.members:SetAlliance(alliance)
	self.membersHeading:SetText("Members")
	self.membersHeading:SizeToContents()
	self.title:SetText(alliance.name)
	self.title:SizeToContents()
end

function PANEL:Think()
	if (CurTime() >= self.nextThink) then
		self:Update()
		self.nextThink = CurTime() + 0.5
	end
end

vgui.Register("exp_Alliance", PANEL, "DScrollPanel")

hook.Add("CreateMenuButtons", "exp_Alliance", function(tabs)
	tabs["alliance"] = function(container)
		container:Add("exp_Alliance")
	end
end)

net.Receive("AllianceMemberInvitation", function()
	local allianceId = net.ReadUInt(32)
	local allianceName = net.ReadString()
	local panel = ix.gui.alliance

	if (not IsValid(panel)) then
		return
	end

	panel.invites = panel.invites or {}

	panel.invites[allianceId] = panel.notices:AddNotice("You have been invited to join the alliance '".. allianceName .."'.", {
		{
			text = "Accept",
			callback = function()
				net.Start("AllianceRequestInviteAccept")
				net.WriteUInt(allianceId, 32)
				net.SendToServer()
			end
		},
		{
			text = "Decline",
			callback = function()
				net.Start("AllianceRequestInviteDecline")
				net.WriteUInt(allianceId, 32)
				net.SendToServer()
			end
		}
	})
end)

net.Receive("AllianceInviteDeclined", function()
	local allianceId = net.ReadUInt(32)
	local panel = ix.gui.alliance

	if (not IsValid(panel)) then
		return
	end

	if (panel.invites and panel.invites[allianceId]) then
		panel.notices:RemoveNotice(panel.invites[allianceId])
		panel.invites[allianceId] = nil
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

net.Receive("AllianceCreateNameInput", function()
	Derma_StringRequest("Alliance", "What is the name of the alliance?", nil, function(text)
		net.Start("AllyCreate")
		net.WriteString(text)
		net.SendToServer()
	end)
end)
