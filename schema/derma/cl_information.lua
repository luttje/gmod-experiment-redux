hook.Remove("CreateMenuButtons", "ixCharInfo")

-- Basically ixCharacterInfo, except using a ModelPanel
local PANEL = {}

local makePartsUnique

--[[
	This gets rid of errors like:
	```
	[PAC3] unique id collision between part[group][0 children][151] and part[group][kevlar][23]
	[PAC3] unique id collision between part[model2][error][152] and part[model2][kevlarvest][24]
	```

	TODO:	What are those id's used for? If they are used within a PAC outfit, to reference other
			parts, then this will break those references.
--]]
function makePartsUnique(partsData)
	for _, v in pairs(partsData) do
		if (istable(v)) then
			if (v.UniqueID) then
				v.UniqueID = pac.Hash()
			end

			makePartsUnique(v)
		end
	end
end

local function attachPartClone(client, uniqueID)
	local itemTable = ix.item.list[uniqueID]
	local pacData = ix.pac.list[uniqueID]

	if (pacData) then
		local isCopy = false

		if (itemTable and itemTable.pacAdjust) then
			pacData = table.Copy(pacData)
			isCopy = true

			makePartsUnique(pacData)

			pacData = itemTable:pacAdjust(pacData, client)
		end

		if (isfunction(client.AttachPACPart)) then
			client:AttachPACPart(pacData)
		else
			pac.SetupENT(client)

			timer.Simple(0.1, function()
				if (IsValid(client) and isfunction(client.AttachPACPart)) then
					if (not isCopy) then
						pacData = table.Copy(pacData)
						makePartsUnique(pacData)
					end

					client:AttachPACPart(pacData)
				end
			end)
		end
	end
end

function PANEL:Init()
	local parent = self:GetParent()

	self:Dock(FILL)
	self:DockMargin(0, ScrH() * 0.05, 0, 0)

	-- Create main horizontal layout
	self.mainLayout = self:Add("DPanel")
	self.mainLayout:Dock(FILL)
	self.mainLayout.Paint = function() end

	-- Create model panel (40% width, left side)
	self.modelPanel = self.mainLayout:Add("ixModelPanel")
	self.modelPanel:Dock(FILL)
	self.modelPanel:SetWide(parent:GetWide() * 0.4)

	-- Default camera values (you can adjust these as needed)
	self.camPos = Vector(47, 23.5, 54)
	self.lookAt = Vector(-33.3, -21.6, 26.5)
	self.fov = 47

	self.modelPanel:SetCamPos(self.camPos)
	self.modelPanel:SetLookAt(self.lookAt)
	self.modelPanel:SetFOV(self.fov)
	self.modelPanel:SetAmbientLight(Color(255, 255, 255, 255))
	self.modelPanel.enableHook = true

	self:UpdateModelPanelModel()

	DEFINE_BASECLASS("ixModelPanel")

	self.modelPanel.DrawModel = function(modelPanel)
		if (not IsValid(ix.gui.menu) or ix.gui.menu.bClosing) then
			return
		end

		local entity = modelPanel:GetEntity()
		if (not entity.AttachPACPart) then
			local parts = LocalPlayer():GetParts()

			for k2, _ in pairs(parts) do
				attachPartClone(entity, k2)
			end
		end

		BaseClass.DrawModel(modelPanel)
	end

	self.modelPanel.OnMousePressed = function(modelPanel, code)
		if (code == MOUSE_RIGHT) then
			self:OnSubpanelRightClick()
		end
	end

	-- Set up model panel entity layout (following cursor logic)
	function self.modelPanel.LayoutEntity(modelPanel, entity)
		local shouldFollowCursor = true
		local client = LocalPlayer()

		if (shouldFollowCursor) then
			-- Get mouse position relative to the model panel itself
			local mouseX, mouseY = modelPanel:ScreenToLocal(gui.MouseX(), gui.MouseY())
			local panelW, panelH = modelPanel:GetSize()

			-- Convert to ratios (0 to 1, with 0.5 being center)
			local xRatio = math.Clamp(mouseX / panelW, 0, 1)
			local yRatio = math.Clamp(mouseY / panelH, 0, 1)

			-- Convert to angles with center point at 0.5, 0.5
			local headYaw = (xRatio - 0.5) * 120
			local headPitch = yRatio * 120

			entity:SetPoseParameter("head_yaw", headYaw)
			entity:SetPoseParameter("head_pitch", headPitch)
			entity:SetIK(false)

			if (modelPanel.copyLocalSequence) then
				entity:SetSequence(client:GetSequence())
				entity:SetPoseParameter("move_yaw", 360 * client:GetPoseParameter("move_yaw") - 180)
			end
		end

		modelPanel:RunAnimation()
	end

	if (MENU_DEBUG_YOU_CAMERA_ENABLED) then
		-- Create camera controls panel (between model and info)
		self.cameraControls = self.mainLayout:Add("DPanel")
		self.cameraControls:Dock(RIGHT)
		self.cameraControls:SetWide(parent:GetWide() * .6)
		self.cameraControls:DockMargin(8, 0, 8, 0)
		self.cameraControls.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)
		end

		-- Camera controls title
		local title = self.cameraControls:Add("DLabel")
		title:SetText("Camera Controls")
		title:SetFont("DermaDefaultBold")
		title:SetTextColor(Color(255, 255, 255))
		title:Dock(TOP)
		title:SetTall(25)
		title:SetContentAlignment(5)
		title:DockMargin(5, 5, 5, 10)

		-- Camera Position Controls
		local camPosLabel = self.cameraControls:Add("DLabel")
		camPosLabel:SetText("Camera Position")
		camPosLabel:SetTextColor(Color(200, 200, 200))
		camPosLabel:Dock(TOP)
		camPosLabel:SetTall(20)
		camPosLabel:DockMargin(5, 0, 5, 2)

		-- X Position
		local xLabel = self.cameraControls:Add("DLabel")
		xLabel:SetText("X:")
		xLabel:SetTextColor(Color(255, 255, 255))
		xLabel:Dock(TOP)
		xLabel:SetTall(15)
		xLabel:DockMargin(10, 0, 5, 0)

		self.camPosX = self.cameraControls:Add("DNumSlider")
		self.camPosX:Dock(TOP)
		self.camPosX:SetTall(20)
		self.camPosX:DockMargin(5, 0, 5, 2)
		self.camPosX:SetMin(-100)
		self.camPosX:SetMax(100)
		self.camPosX:SetDecimals(1)
		self.camPosX:SetValue(self.camPos.x)
		self.camPosX.OnValueChanged = function(slider, val)
			self.camPos.x = val
			self.modelPanel:SetCamPos(self.camPos)
		end

		-- Y Position
		local yLabel = self.cameraControls:Add("DLabel")
		yLabel:SetText("Y:")
		yLabel:SetTextColor(Color(255, 255, 255))
		yLabel:Dock(TOP)
		yLabel:SetTall(15)
		yLabel:DockMargin(10, 0, 5, 0)

		self.camPosY = self.cameraControls:Add("DNumSlider")
		self.camPosY:Dock(TOP)
		self.camPosY:SetTall(20)
		self.camPosY:DockMargin(5, 0, 5, 2)
		self.camPosY:SetMin(-100)
		self.camPosY:SetMax(100)
		self.camPosY:SetDecimals(1)
		self.camPosY:SetValue(self.camPos.y)
		self.camPosY.OnValueChanged = function(slider, val)
			self.camPos.y = val
			self.modelPanel:SetCamPos(self.camPos)
		end

		-- Z Position
		local zLabel = self.cameraControls:Add("DLabel")
		zLabel:SetText("Z:")
		zLabel:SetTextColor(Color(255, 255, 255))
		zLabel:Dock(TOP)
		zLabel:SetTall(15)
		zLabel:DockMargin(10, 0, 5, 0)

		self.camPosZ = self.cameraControls:Add("DNumSlider")
		self.camPosZ:Dock(TOP)
		self.camPosZ:SetTall(20)
		self.camPosZ:DockMargin(5, 0, 5, 8)
		self.camPosZ:SetMin(-50)
		self.camPosZ:SetMax(150)
		self.camPosZ:SetDecimals(1)
		self.camPosZ:SetValue(self.camPos.z)
		self.camPosZ.OnValueChanged = function(slider, val)
			self.camPos.z = val
			self.modelPanel:SetCamPos(self.camPos)
		end

		-- Look At Controls
		local lookAtLabel = self.cameraControls:Add("DLabel")
		lookAtLabel:SetText("Look At Position")
		lookAtLabel:SetTextColor(Color(200, 200, 200))
		lookAtLabel:Dock(TOP)
		lookAtLabel:SetTall(20)
		lookAtLabel:DockMargin(5, 0, 5, 2)

		-- Look At X
		local lookXLabel = self.cameraControls:Add("DLabel")
		lookXLabel:SetText("X:")
		lookXLabel:SetTextColor(Color(255, 255, 255))
		lookXLabel:Dock(TOP)
		lookXLabel:SetTall(15)
		lookXLabel:DockMargin(10, 0, 5, 0)

		self.lookAtX = self.cameraControls:Add("DNumSlider")
		self.lookAtX:Dock(TOP)
		self.lookAtX:SetTall(20)
		self.lookAtX:DockMargin(5, 0, 5, 2)
		self.lookAtX:SetMin(-50)
		self.lookAtX:SetMax(50)
		self.lookAtX:SetDecimals(1)
		self.lookAtX:SetValue(self.lookAt.x)
		self.lookAtX.OnValueChanged = function(slider, val)
			self.lookAt.x = val
			self.modelPanel:SetLookAt(self.lookAt)
		end

		-- Look At Y
		local lookYLabel = self.cameraControls:Add("DLabel")
		lookYLabel:SetText("Y:")
		lookYLabel:SetTextColor(Color(255, 255, 255))
		lookYLabel:Dock(TOP)
		lookYLabel:SetTall(15)
		lookYLabel:DockMargin(10, 0, 5, 0)

		self.lookAtY = self.cameraControls:Add("DNumSlider")
		self.lookAtY:Dock(TOP)
		self.lookAtY:SetTall(20)
		self.lookAtY:DockMargin(5, 0, 5, 2)
		self.lookAtY:SetMin(-50)
		self.lookAtY:SetMax(50)
		self.lookAtY:SetDecimals(1)
		self.lookAtY:SetValue(self.lookAt.y)
		self.lookAtY.OnValueChanged = function(slider, val)
			self.lookAt.y = val
			self.modelPanel:SetLookAt(self.lookAt)
		end

		-- Look At Z
		local lookZLabel = self.cameraControls:Add("DLabel")
		lookZLabel:SetText("Z:")
		lookZLabel:SetTextColor(Color(255, 255, 255))
		lookZLabel:Dock(TOP)
		lookZLabel:SetTall(15)
		lookZLabel:DockMargin(10, 0, 5, 0)

		self.lookAtZ = self.cameraControls:Add("DNumSlider")
		self.lookAtZ:Dock(TOP)
		self.lookAtZ:SetTall(20)
		self.lookAtZ:DockMargin(5, 0, 5, 8)
		self.lookAtZ:SetMin(0)
		self.lookAtZ:SetMax(100)
		self.lookAtZ:SetDecimals(1)
		self.lookAtZ:SetValue(self.lookAt.z)
		self.lookAtZ.OnValueChanged = function(slider, val)
			self.lookAt.z = val
			self.modelPanel:SetLookAt(self.lookAt)
		end

		-- FOV Control
		local fovLabel = self.cameraControls:Add("DLabel")
		fovLabel:SetText("Field of View")
		fovLabel:SetTextColor(Color(200, 200, 200))
		fovLabel:Dock(TOP)
		fovLabel:SetTall(20)
		fovLabel:DockMargin(5, 0, 5, 2)

		self.fovSlider = self.cameraControls:Add("DNumSlider")
		self.fovSlider:Dock(TOP)
		self.fovSlider:SetTall(20)
		self.fovSlider:DockMargin(5, 0, 5, 8)
		self.fovSlider:SetMin(10)
		self.fovSlider:SetMax(120)
		self.fovSlider:SetDecimals(0)
		self.fovSlider:SetValue(self.fov)
		self.fovSlider.OnValueChanged = function(slider, val)
			self.fov = val
			self.modelPanel:SetFOV(self.fov)
		end

		-- Reset button
		local resetBtn = self.cameraControls:Add("DButton")
		resetBtn:SetText("Reset to Default")
		resetBtn:Dock(TOP)
		resetBtn:SetTall(25)
		resetBtn:DockMargin(5, 0, 5, 5)
		resetBtn.DoClick = function()
			self.camPos = Vector(32, 32, 45)
			self.lookAt = Vector(0, 0, 45)
			self.fov = 70

			self.camPosX:SetValue(self.camPos.x)
			self.camPosY:SetValue(self.camPos.y)
			self.camPosZ:SetValue(self.camPos.z)
			self.lookAtX:SetValue(self.lookAt.x)
			self.lookAtY:SetValue(self.lookAt.y)
			self.lookAtZ:SetValue(self.lookAt.z)
			self.fovSlider:SetValue(self.fov)

			self.modelPanel:SetCamPos(self.camPos)
			self.modelPanel:SetLookAt(self.lookAt)
			self.modelPanel:SetFOV(self.fov)
		end
	end

	-- Create info panel container (remaining width, right side)
	self.infoContainer = self.mainLayout:Add("DScrollPanel")
	self.infoContainer:Dock(RIGHT)
	self.infoContainer:SetWide(parent:GetWide() * .6)
	self.infoContainer:DockMargin(0, 0, 0, 0)
	self.infoContainer.VBar:SetWide(0)

	if (MENU_DEBUG_YOU_CAMERA_ENABLED) then
		self.infoContainer:SetVisible(false)
	end

	-- Move all existing content creation to the info container
	-- entry setup
	local suppress = {}
	hook.Run("CanCreateCharacterInfo", suppress)

	if (not suppress.time) then
		local format = ix.option.Get("24hourTime", false) and "%A, %B %d, %Y. %H:%M" or "%A, %B %d, %Y. %I:%M %p"

		self.time = self.infoContainer:Add("DLabel")
		self.time:SetFont("ixMediumFont")
		self.time:SetTall(28)
		self.time:SetContentAlignment(5)
		self.time:Dock(TOP)
		self.time:SetTextColor(color_white)
		self.time:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self.time:DockMargin(0, 0, 0, 32)
		self.time:SetText(ix.date.GetFormatted(format))
		self.time.Think = function(this)
			if ((this.nextTime or 0) < CurTime()) then
				this:SetText(ix.date.GetFormatted(format))
				this.nextTime = CurTime() + 0.5
			end
		end
	end

	if (not suppress.name) then
		self.name = self.infoContainer:Add("ixLabel")
		self.name:Dock(TOP)
		self.name:DockMargin(0, 0, 0, 8)
		self.name:SetFont("ixMenuButtonHugeFont")
		self.name:SetContentAlignment(5)
		self.name:SetTextColor(color_white)
		self.name:SetPadding(8)
		self.name:SetScaleWidth(true)
	end

	if (not suppress.description) then
		self.description = self.infoContainer:Add("DLabel")
		self.description:Dock(TOP)
		self.description:DockMargin(0, 0, 0, 8)
		self.description:SetFont("ixMenuButtonFont")
		self.description:SetTextColor(color_white)
		self.description:SetContentAlignment(5)
		self.description:SetMouseInputEnabled(true)
		self.description:SetCursor("hand")

		self.description.Paint = function(this, width, height)
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(0, 0, width, height)
		end

		self.description.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT) then
				ix.command.Send("CharDesc")

				if (IsValid(ix.gui.menu)) then
					ix.gui.menu:Remove()
				end
			end
		end

		self.description.SizeToContents = function(this)
			if (this.bWrap) then
				-- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
				return
			end

			local width, height = this:GetContentSize()

			if (width > self.infoContainer:GetWide()) then
				this:SetWide(self.infoContainer:GetWide())
				this:SetTextInset(16, 8)
				this:SetWrap(true)
				this:SizeToContentsY()
				this:SetTall(this:GetTall() + 16) -- eh

				-- wrapping doesn't like middle alignment so we'll do top-center
				self.description:SetContentAlignment(8)
				this.bWrap = true
			else
				this:SetSize(width + 16, height + 16)
			end
		end
	end

	if (not suppress.characterInfo) then
		self.characterInfo = self.infoContainer:Add("Panel")
		self.characterInfo.list = {}
		self.characterInfo:Dock(TOP) -- no dock margin because this is handled by ixListRow
		self.characterInfo.SizeToContents = function(this)
			local height = 0

			for _, v in ipairs(this:GetChildren()) do
				if (IsValid(v) and v:IsVisible()) then
					local _, top, _, bottom = v:GetDockMargin()
					height = height + v:GetTall() + top + bottom
				end
			end

			this:SetTall(height)
		end

		if (not suppress.faction) then
			self.faction = self.characterInfo:Add("ixListRow")
			self.faction:SetList(self.characterInfo.list)
			self.faction:Dock(TOP)
		end

		if (not suppress.class) then
			self.class = self.characterInfo:Add("ixListRow")
			self.class:SetList(self.characterInfo.list)
			self.class:Dock(TOP)
		end

		if (not suppress.money) then
			self.money = self.characterInfo:Add("ixListRow")
			self.money:SetList(self.characterInfo.list)
			self.money:Dock(TOP)
			self.money:SizeToContents()
		end

		hook.Run("CreateCharacterInfo", self.characterInfo)
		self.characterInfo:SizeToContents()
	end

	-- no need to update since we aren't showing the attributes panel
	if (not suppress.attributes) then
		local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

		if (character) then
			self.attributes = self.infoContainer:Add("ixCategoryPanel")
			self.attributes:SetText(L("attributes"))
			self.attributes:Dock(TOP)
			self.attributes:DockMargin(0, 0, 0, 8)

			local boost = character:GetBoosts()
			local bFirst = true

			for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
				local attributeBoost = 0

				if (boost[k]) then
					for _, bValue in pairs(boost[k]) do
						attributeBoost = attributeBoost + bValue
					end
				end

				local bar = self.attributes:Add("ixAttributeBar")
				bar:Dock(TOP)

				if (not bFirst) then
					bar:DockMargin(0, 3, 0, 0)
				else
					bFirst = false
				end

				local value = character:GetAttribute(k, 0)

				if (attributeBoost) then
					bar:SetValue(value - attributeBoost or 0)
				else
					bar:SetValue(value)
				end

				local maximum = v.maxValue or ix.config.Get("maxAttributes", 100)
				bar:SetMax(maximum)
				bar:SetReadOnly()
				bar:SetText(Format("%s [%.1f/%.1f] (%.1f%%)", L(v.name), value, maximum, value / maximum * 100))

				if (attributeBoost) then
					bar:SetBoost(attributeBoost)
				end
			end

			self.attributes:SizeToContents()
		end
	end

	hook.Run("CreateCharacterInfoCategory", self)
end

local function getBodyGroupsString(entity)
	local bodygroups = ""

	for i = 0, entity:GetNumBodyGroups() - 1 do
		local name = entity:GetBodygroupName(i)
		local state = entity:GetBodygroup(i)

		bodygroups = bodygroups .. tostring(state)
	end

	return bodygroups
end

function PANEL:UpdateModelPanelModel()
	local bodygroups = getBodyGroupsString(LocalPlayer())

	-- Update the model panel with the character's model, skin, bodygroups and pac setup
	self.modelPanel:SetModel(
		LocalPlayer():GetModel(),
		LocalPlayer():GetSkin(),
		bodygroups
	)
end

function PANEL:Update(character)
	if (not character) then
		return
	end

	self:UpdateModelPanelModel()

	local faction = ix.faction.indices[character:GetFaction()]
	local class = ix.class.list[character:GetClass()]

	if (self.name) then
		self.name:SetText(character:GetName())

		if (faction) then
			self.name.backgroundColor = ColorAlpha(faction.color, 150) or Color(0, 0, 0, 150)
		end

		self.name:SizeToContents()
	end

	if (self.description) then
		self.description:SetText(character:GetDescription())
		self.description:SizeToContents()
	end

	if (self.faction) then
		self.faction:SetLabelText(L("faction"))
		self.faction:SetText(L(faction.name))
		self.faction:SizeToContents()
	end

	if (self.class) then
		-- don't show class label if the class is the same name as the faction
		if (class and class.name ~= faction.name) then
			self.class:SetLabelText(L("class"))
			self.class:SetText(L(class.name))
			self.class:SizeToContents()
		else
			self.class:SetVisible(false)
		end
	end

	if (self.money) then
		self.money:SetLabelText(L("money"))
		self.money:SetText(ix.currency.Get(character:GetMoney()))
		self.money:SizeToContents()
	end

	hook.Run("UpdateCharacterInfo", self.characterInfo, character)

	self.characterInfo:SizeToContents()

	hook.Run("UpdateCharacterInfoCategory", self, character)
end

function PANEL:OnSubpanelRightClick()
	-- properties.OpenEntityMenu(LocalPlayer())
end

vgui.Register("expCharacterInfo", PANEL, "EditablePanel")

-- The same as ixCharInfo, but without a character overview
hook.Add("CreateMenuButtons", "expCharInfo", function(tabs)
	tabs["you"] = {
		-- bHideBackground = true,
		buttonColor = team.GetColor(LocalPlayer():Team()),
		Create = function(info, container)
			container.infoPanel = container:Add("expCharacterInfo")

			container.OnMouseReleased = function(this, key)
				if (key == MOUSE_RIGHT) then
					this.infoPanel:OnSubpanelRightClick()
				end
			end
		end,
		OnSelected = function(info, container)
			container.infoPanel:Update(LocalPlayer():GetCharacter())
			-- ix.gui.menu:SetCharacterOverview(true)
		end,
		OnDeselected = function(info, container)
			-- ix.gui.menu:SetCharacterOverview(false)
		end
	}
end)
