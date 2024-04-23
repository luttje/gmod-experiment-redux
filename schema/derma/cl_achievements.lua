local rowPaintFunctions = {
	function(width, height)
	end,

	function(width, height)
		surface.SetDrawColor(30, 30, 30, 25)
		surface.DrawRect(0, 0, width, height)
	end
}

-- exp_Achievement
PANEL = {}

AccessorFunc(PANEL, "paintFunction", "BackgroundPaintFunction")

function PANEL:Init()
	self:SetTall(64)

	self.icon = self:Add("expDynamicIcon")
	self.icon:Dock(LEFT)

	local lightShadow = Color(0, 0, 0, 155)

	self.progressLabel = self:Add("DLabel")
	self.progressLabel:DockMargin(0, 0, 4, 4)
	self.progressLabel:Dock(RIGHT)
	self.progressLabel:SetText("0 / 0")
	self.progressLabel:SetFont("ixSmallFont")
	self.progressLabel:SetExpensiveShadow(1, lightShadow)
	self.progressLabel:SetContentAlignment(5)

	self.name = self:Add("DLabel")
	self.name:DockMargin(8, 4, 0, 0)
	self.name:Dock(TOP)
	self.name:SetTextColor(color_white)
	self.name:SetFont("ixGenericFont")
	self.name:SetExpensiveShadow(1, lightShadow)

	self.description = self:Add("DLabel")
	self.description:DockMargin(8, 0, 0, 0)
	self.description:Dock(TOP)
	self.description:SetFont("ixSmallFont")
	self.description:SetExpensiveShadow(1, lightShadow)

	self.paintFunction = rowPaintFunctions[1]
end

function PANEL:SetBackgroundPaintFunction(func)
	self.paintFunction = func
end

function PANEL:SetAchievement(achievement)
	self.achievement = achievement

	self:Update()
end

function PANEL:Update()
	if (not self.achievement) then
		return
	end

    self.name:SetText(self.achievement.name)
	self.name:SizeToContents()
	self.description:SetText(self.achievement.description .. " (rewards " .. ix.currency.Get(self.achievement.reward) .. ")")
	self.description:SizeToContents()

	self.progressLabel:SetText(Schema.achievement.GetProgress(self.achievement.uniqueID) .. " / " .. self.achievement.maximum)

	local opacity = 255

    if (Schema.achievement.HasAchieved(self.achievement.uniqueID)) then
        self.icon:SetBadge({
			spritesheet = Material("experiment-redux/flatmsicons32.png"),
			x = 29,
			y = 5,
			size = 32,
		}, derma.GetColor("Success", self))
    else
        opacity = 20
    end

	self.achievedOpacity = opacity

	self.icon:SetBack(
		self.achievement.backgroundImage or "experiment-redux/symbol_background",
		self.achievement.backgroundColor or Color(48, 93, 124, 255),
		opacity
	)
	self.icon:SetSymbol(self.achievement.foregroundImage, opacity)

	local whiteOpacity = Color(color_white.r, color_white.g, color_white.b, opacity)

	self.name:SetTextColor(whiteOpacity)
	self.description:SetTextColor(whiteOpacity)
	self.color = whiteOpacity
end

function PANEL:Paint(width, height)
	self.paintFunction(width, height)

	if (not self.achievement) then
		return
	end

	local color = Color(self.color.r, self.color.g, self.color.b, self.achievedOpacity or self.color.a)

	local progress = Schema.achievement.GetProgress(self.achievement.uniqueID)
	local maximum = self.achievement.maximum
	local width = math.Clamp((width / maximum) * progress, 0, width)

	local success = derma.GetColor("Success", self)
	draw.RoundedBox(0, 0, 0, width, height, Color(success.r, success.g, success.b, color.a * .5))
end

vgui.Register("exp_Achievement", PANEL, "EditablePanel")

-- exp_Achievements
PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    self.achievements = {}
    self.nextThink = 0

    local sortedAchievements = table.ClearKeys(Schema.achievement.GetAll())

    table.SortByMember(sortedAchievements, "name", true)

	for _, achievement in ipairs(sortedAchievements) do
        local panel = self:Add("exp_Achievement")
        panel:SetAchievement(achievement)
        panel:Dock(TOP)
		panel:DockMargin(4, 4, 4, 4)

        self.achievements[#self.achievements + 1] = panel
    end

    ix.gui.achievementsPanel = self
end

function PANEL:Update()
	for i = 1, #self.achievements do
		local id = i % 2 == 0 and 1 or 2
		local achievementPanel = self.achievements[i]
		achievementPanel:SetBackgroundPaintFunction(rowPaintFunctions[id])
		achievementPanel:Update()
	end
end

function PANEL:Think()
	if (CurTime() >= self.nextThink) then
		self:Update()
		self.nextThink = CurTime() + 0.5
	end
end

vgui.Register("exp_Achievements", PANEL, "DScrollPanel")

hook.Add("CreateMenuButtons", "expAddAchievementsMenuButton", function(tabs)
	tabs["achievements"] = function(container)
		container:Add("exp_Achievements")
	end
end)
