local PLUGIN = PLUGIN

PLUGIN.name = "Single Character"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Only allow one character per player, modify existing menus to remove redundant buttons."

-- https://github.com/luttje/gmod-experiment-redux/issues/23
ix.config.SetDefault("maxCharacters", 1)

ix.lang.AddTable("english", {
	loadTitle = "Load your Character",
})

if (not CLIENT) then
	return
end

-- Recurse through the children of the parent panel to find an element with the specified text
local function findElementWithText(parent, text)
	for _, child in ipairs(parent:GetChildren()) do
		if (child.GetText and child:GetText() == text) then
			return child
		end

		if (child.GetChildren) then
			local element = findElementWithText(child, text)

			-- If we found the button, return it
			if (element) then
				return element
			end
		end
	end
end

local function removeElementWithText(parent, text)
	local element = findElementWithText(parent, text)

	if (IsValid(element)) then
		element:Remove()
	end
end

-- Disable load and create character buttons, head straight for either the character list or the character creation screen.
function PLUGIN:OnCharacterMenuCreated(panel)
    if (ix.config.Get("maxCharacters") ~= 1) then
        return
    end

    local function showCorrectPanel()
        local hasCharacter = #ix.characters > 0

        panel.mainPanel:SetVisible(false)
        panel.mainPanel.loadButton:SetDisabled(false)

        if (hasCharacter) then
            panel.loadCharacterPanel:SlideUp(0)
        else
            panel.newCharacterPanel:SlideUp(0)
        end

        removeElementWithText(
            panel.loadCharacterPanel.panel,
            L("return"):utf8upper()
        )

        removeElementWithText(
            panel.newCharacterPanel.description,
            L("return"):utf8upper()
        )
    end

    panel.mainPanel.Undim = function()
        showCorrectPanel()
    end

    panel.OnCharacterDeleted = function(character)
        panel.loadCharacterPanel:SlideDown()
        panel.newCharacterPanel:SlideUp(0)
    end

    -- I don't like that stencil effect on the main panel, so I'm removing it
	-- panel.loadCharacterPanel.carousel.Paint = function(self, width, height)
	-- 	cam.Start3D(self.cameraPosition, self.cameraAngle, modelFOV, x, y, width, height)
	-- 	render.SuppressEngineLighting(true)
	-- 	render.SetLightingOrigin(self.activeCharacter:GetPos())
	-- 	render.SetModelLighting(0, 1.5, 1.5, 1.5)

	-- 	for i = 1, 4 do
	-- 		render.SetModelLighting(i, 0.4, 0.4, 0.4)
	-- 	end

	-- 	render.SetModelLighting(5, 0.04, 0.04, 0.04)

	-- 	self:LayoutEntity(self.activeCharacter)
	-- 	self.activeCharacter:DrawModel()

	-- 	render.SetScissorRect(0, 0, 0, 0, false)
	-- 	render.SuppressEngineLighting(false)
	-- 	cam.End3D()

	-- 	self.lastPaint = RealTime()
	-- end

    showCorrectPanel()
end

-- Note that this hook doesnt exist without `expMenu` overriding ixMenu
function PLUGIN:OnMainMenuCreated(panel)
	if (ix.config.Get("maxCharacters") ~= 1) then
		return
	end

	removeElementWithText(
		panel.buttons,
		L("characters"):utf8upper()
	)
end
