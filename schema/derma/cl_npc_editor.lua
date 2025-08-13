do
  --- @class expNpcEditor : DFrame
  local PANEL = {}

  --- Clears a listview, removing all items.
  --- @param listView DListView
  local function clearListView(listView)
    for _, line in pairs(listView:GetLines()) do
      listView:RemoveLine(line:GetID())
    end
  end

  --- Called when the panel is initialized.
  function PANEL:Init()
    self:SetTitle("Creating a new NPC")

    self.lblTitle:SetPos(5, 4)
    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)

    --- Called when the button is clicked.
    function self.btnClose.DoClick(button)
      local function close()
        CloseDermaMenus()

        self:Close()
      end

      if (self.hasUnsavedChanges) then
        Derma_Query(
          "You have unsaved changes, are you sure you want to close?",
          "Unsaved Changes",
          "Yes",
          close,
          "No"
        )

        return
      end

      close()
    end

    self.propertySheet = vgui.Create("DPropertySheet", self)
    self.propertySheet:Dock(FILL)

    self.settingsPanel = vgui.Create("DPanelList")
    self.settingsPanel:SetPadding(2)
    self.settingsPanel:SetSpacing(4)
    self.settingsPanel:SizeToContents()
    self.settingsPanel:EnableVerticalScrollbar()

    self.propertySheet:AddSheet(
      "Settings",
      self.settingsPanel,
      "icon16/wrench.png",
      nil,
      nil,
      "View the settings for this npc."
    )

    self.interactionSetsPanel = vgui.Create("DPanelList")
    self.interactionSetsPanel:SetPadding(2)
    self.interactionSetsPanel:SetSpacing(4)
    self.interactionSetsPanel:SizeToContents()
    self.interactionSetsPanel:EnableVerticalScrollbar()

    self.interactionSetsSheet = self.propertySheet:AddSheet(
      "Interaction Sets",
      self.interactionSetsPanel,
      "icon16/comments.png",
      nil,
      nil,
      "Set the interactions for this npc."
    )
    self.interactionSetsSheet.Tab:SetEnabled(false)
    self.interactionSetsSheet.Tab:SetAlpha(80)

    -- Setup all faction models for the model list.
    local models = {}

    for _, faction in pairs(Schema.faction.GetAll()) do
      models = table.Add(models, faction.models[string.lower(GENDER_FEMALE)] or {})
      models = table.Add(models, faction.models[string.lower(GENDER_MALE)] or {})
    end

    self.models = models

    self.randomGenerator = vgui.Create("DButton")
    self.randomGenerator:Dock(TOP)
    self.randomGenerator:DockMargin(4, 4, 4, 4)
    self.randomGenerator:SetText("Randomize")
    self.randomGenerator:SizeToContents()
    self.randomGenerator:SetTall(32)

    function self.randomGenerator.DoClick(button)
      local name = Schema.GetRandomName()
      local description = Schema.GetRandomPhysicalDescription()
      local model = models[math.random(1, #models)]

      self.nameTextEntry:SetValue(name)
      self.descriptionTextEntry:SetValue(description)

      local uniqueID = string.lower(string.gsub(name, "%s", "_"))
      self.uniqueIDTextEntry:SetValue(uniqueID)

      self:SelectModel(model)
    end

    self.settingsPanel:AddItem(self.randomGenerator)

    self.submitButton = vgui.Create("DButton", self)
    self.submitButton:SetText("Submit")
    self.submitButton:SizeToContents()
    self.submitButton:SetTall(32)
    self.submitButton:Dock(BOTTOM)
    self.submitButton:DockMargin(4, 4, 4, 4)

    self.submitButton.DoClick = function(submitButton)
      self:Submit()
    end

    self:InitSettings()
    self:InitInteractionSets()

    self.hasUnsavedChanges = false
  end

  function PANEL:OnKeyCodeReleased(keyCode)
    if (keyCode == KEY_ESCAPE) then
      self:Close()
    end
  end

  --- Sets up setting elements.
  function PANEL:InitSettings()
    local generalForm = vgui.Create("expForm")
    generalForm:SetPadding(4)
    generalForm:SetName("General")

    self.settingsPanel:AddItem(generalForm)

    --[[
			General
		--]]

    self.uniqueIDTextEntry = generalForm:TextEntry("UniqueID")

    function self.uniqueIDTextEntry.OnChange(uniqueIDTextEntry)
      self.hasUnsavedChanges = true
    end

    self.nameTextEntry = generalForm:TextEntry("Name")

    function self.nameTextEntry.OnChange(nameTextEntry)
      self.hasUnsavedChanges = true
    end

    self.descriptionTextEntry = generalForm:TextEntry("Description")

    function self.descriptionTextEntry.OnChange(descriptionTextEntry)
      self.hasUnsavedChanges = true
    end

    --[[
			Appearance
		--]]

    local appearanceForm = vgui.Create("expForm")
    appearanceForm:SetPadding(4)
    appearanceForm:SetName("Appearance")

    self.settingsPanel:AddItem(appearanceForm)

    self.modelTextEntry = appearanceForm:TextEntry("Model")

    function self.modelTextEntry.OnChange(modelTextEntry)
      self.hasUnsavedChanges = true
    end

    self.modelItemsList = vgui.Create("DPanelList", self)
    self.modelItemsList:SetPadding(2)
    self.modelItemsList:SetSpacing(4)
    self.modelItemsList:EnableHorizontal(true)
    self.modelItemsList:EnableVerticalScrollbar(true)

    appearanceForm:AddItem(self.modelItemsList)

    local spawnIcon

    for _, modelPath in pairs(self.models) do
      spawnIcon = Schema.CreateColoredSpawnIcon(self)
      spawnIcon:SetModel(modelPath)

      -- Called when the spawn icon is clicked.
      function spawnIcon.DoClick(spawnIcon)
        if (IsValid(self.selectedSpawnIcon)) then
          self.selectedSpawnIcon:SetColor(nil)
        end

        spawnIcon:SetColor(Color(255, 0, 0, 255))

        self.selectedSpawnIcon = spawnIcon
        self.modelTextEntry:SetValue(modelPath)
        self.hasUnsavedChanges = true
      end

      self.modelItemsList:AddItem(spawnIcon)
    end

    --[[
			Voice
		--]]

    local voiceForm = vgui.Create("expForm")
    voiceForm:SetPadding(4)
    voiceForm:SetName("Voice")

    self.settingsPanel:AddItem(voiceForm)

    self.voicePitchSlider = voiceForm:NumSlider("Voice Pitch", nil, 0, 255, 0)

    function self.voicePitchSlider.OnValueChanged(voicePitchSlider, value)
      self.hasUnsavedChanges = true

      if (Schema.Throttle("NpcEditorVoicePitch", 1)) then
        return
      end

      local model = self.modelTextEntry:GetValue()
      local randomVoiceLines = Schema.npc.GetRandomVoiceSet(model)
      local count = #randomVoiceLines

      if (count == 0) then
        return
      end

      if (value == 0) then
        return
      end

      local randomLine = randomVoiceLines[math.random(count)]

      EmitSound(randomLine, LocalPlayer():GetPos(), -1, nil, 0.2, nil, nil, value)
    end
  end

  function PANEL:CreateConditionsPanel()
    local conditionsPanel = vgui.Create("EditablePanel")

    local addConditionButton = vgui.Create("DButton", conditionsPanel)
    addConditionButton:Dock(TOP)
    addConditionButton:DockMargin(4, 4, 4, 4)
    addConditionButton:SetText("Add Condition")

    local conditionsListView = vgui.Create("expListView", conditionsPanel)
    conditionsListView:SetMultiSelect(false)
    conditionsListView:SetSortable(false)
    conditionsListView:Dock(FILL)
    conditionsListView:DockMargin(4, 4, 4, 4)
    conditionsListView:AddColumn("Type")
    conditionsListView:AddColumn("Parameters")

    local function openConditionEditDialog(conditionUniqueID, editRow)
      local parameters = editRow and editRow:GetColumnData(2)
      local title = editRow and "Edit Condition" or "Add Condition"

      local dialog = vgui.Create("DFrame")
      dialog:SetAlwaysOnTop()
      dialog:SetTitle(title)
      dialog:SetSize(400, 300)
      dialog:Center()
      dialog:MakePopup()
      dialog:SetToRemoveOnceInvalid(conditionsListView)

      local scrollPanel = vgui.Create("DScrollPanel", dialog)
      scrollPanel:Dock(FILL)

      local selectorForm = vgui.Create("expForm", scrollPanel)
      selectorForm:SetIsHeadless(true)
      selectorForm:Dock(TOP)

      local condition = Schema.npcCondition.Get(conditionUniqueID)

      if (not condition) then
        ix.util.SchemaErrorNoHaltFormatted("Invalid condition uniqueID: %s", conditionUniqueID)
        return
      end

      local selectorName = condition.selectorName
      local selectorType = condition.selectorType

      selectorForm:SetName(selectorName)

      local selector = vgui.Create("expParameter")
      selector:SetupParameter(selectorName, selectorType, parameters, self.npcToEdit)
      selector:DoSetupControl()
      selectorForm:AddItem(selector)

      local submitButton = vgui.Create("DButton", dialog)
      submitButton:SetText(editRow and "Save" or "Add")
      submitButton:Dock(BOTTOM)

      submitButton.DoClick = function(submitButton)
        local conditionValue = selector:GetValue()

        if (conditionValue == nil) then
          Schema.player.NotifyLocal(("You must select an %s!"):format(selectorName:lower()))
          return
        end

        if (editRow) then
          editRow:SetColumnData(2, conditionValue)
        else
          local condition = Schema.npcCondition.Get(conditionUniqueID)

          local formatter

          if (condition.listViewFormatter) then
            formatter = function(value)
              return condition.listViewFormatter(value, self.npcData, self)
            end
          end

          conditionsListView:AddFormattedLine(
            { conditionUniqueID },
            { conditionValue, formatter }
          )
        end

        dialog:Close()

        self.hasUnsavedChanges = true
      end
    end

    conditionsListView.DoDoubleClick = function(conditionsListView, index, row)
      openConditionEditDialog(row:GetColumnData(1), row)
    end

    conditionsListView.OnRowRightClick = function(conditionsListView, index, row)
      local menu = DermaMenu()

      menu:AddOption("Edit", function()
        openConditionEditDialog(row:GetColumnData(1), row)
      end)

      menu:AddOption("Remove", function()
        conditionsListView:RemoveLine(row:GetID())

        self.hasUnsavedChanges = true
      end)

      menu:Open()
    end

    addConditionButton.DoClick = function(addConditionButton)
      local menu = DermaMenu()

      local conditions = Schema.npcCondition.GetAll()

      for uniqueID, condition in pairs(conditions) do
        menu:AddOption(condition.name, function()
          openConditionEditDialog(uniqueID)
        end)
      end

      menu:Open()
    end

    conditionsListView.SetupWithData = function(conditionsListView, conditions)
      if (not conditions) then
        return
      end

      for _, condition in pairs(conditions) do
        local conditionInfo = Schema.npcCondition.Get(condition.uniqueID)

        if (not conditionInfo) then
          ix.util.SchemaErrorNoHaltFormatted("Invalid condition uniqueID: %s", condition.uniqueID)
          return
        end

        local formatter

        if (conditionInfo.listViewFormatter) then
          formatter = function(value)
            return conditionInfo.listViewFormatter(value, self.npcData, self)
          end
        end

        conditionsListView:AddFormattedLine(
          { condition.uniqueID },
          { condition.parameters, formatter }
        )
      end
    end

    return conditionsPanel, conditionsListView
  end

  function PANEL:CreateEffectsPanel()
    local effectsPanel = vgui.Create("EditablePanel")

    local addEffectButton = vgui.Create("DButton", effectsPanel)
    addEffectButton:Dock(TOP)
    addEffectButton:DockMargin(4, 4, 4, 4)
    addEffectButton:SetText("Add Effect")

    local effectsListView = vgui.Create("expListView", effectsPanel)
    effectsListView:Dock(TOP)
    effectsListView:DockMargin(4, 4, 4, 4)
    effectsListView:SetMultiSelect(false)
    effectsListView:SetSortable(false)
    effectsListView:SetTall(180)
    effectsListView:AddColumn("Effect")
    effectsListView:AddColumn("Parameters")

    local function parameterFormatter(parameters, npc, editor)
      return util.TableToJSON(parameters)
    end

    effectsListView.SetupWithData = function(effectsListView, effects)
      clearListView(effectsListView)

      for _, effect in pairs(effects) do
        effectsListView:AddFormattedLine(
          { effect.uniqueID },
          { effect.parameters, parameterFormatter }
        )
      end
    end

    local function editEffect(editRow)
      local effectUniqueID = editRow and editRow:GetColumnData(1)
      local parameters = editRow and editRow:GetColumnData(2)
      local title = editRow and "Edit Effect" or "Add Effect"

      local effectDialog = vgui.Create("DFrame")
      effectDialog:SetAlwaysOnTop()
      effectDialog:SetTitle(title)
      effectDialog:SetSize(400, 300)
      effectDialog:MakePopup()
      effectDialog:SetToRemoveOnceInvalid(effectsListView)
      effectDialog:CenterHorizontal(0.65)
      effectDialog:CenterVertical(0.65)

      local scrollPanel = vgui.Create("DScrollPanel", effectDialog)
      scrollPanel:Dock(FILL)

      local effectForm = vgui.Create("expForm", scrollPanel)
      effectForm:SetIsHeadless(true)
      effectForm:Dock(TOP)
      effectForm:SetName(title)

      local availableEffects = table.Copy(Schema.npcEffect.GetAll())

      hook.Run("NpcEditorEffectsAdd", availableEffects)
      hook.Run("NpcEditorEffectsDestroy", availableEffects)
      hook.Run("NpcEditorEffectsSetup", availableEffects)

      local availableEffectsMap = {}

      for _, effect in pairs(availableEffects) do
        availableEffectsMap[effect.uniqueID] = effect
      end

      local effectComboBox = effectForm:ComboBox("Effect")
      effectComboBox:SetSortItems(false)
      effectComboBox:AddChoice("Select an effect...", "", not effectUniqueID)

      effectComboBox.OnSelect = function(effectComboBox, index, value, data)
        local effect = availableEffectsMap[data]

        if (not effect) then
          return
        end

        effectForm:ClearExcept(effectComboBox)

        self.parametersSelector = vgui.Create("expParameters")
        self.parametersSelector:SetupParameters(effect.parameters, parameters, self.npcToEdit)
        effectForm:AddItem(self.parametersSelector)
      end

      for _, effect in pairs(availableEffects) do
        effectComboBox:AddChoice(effect.name, effect.uniqueID, effectUniqueID == effect.uniqueID)
      end

      local submitButton = vgui.Create("DButton", effectDialog)
      submitButton:SetText(editRow and "Save" or "Add")
      submitButton:Dock(BOTTOM)

      submitButton.DoClick = function(submitButton)
        local _, effectUniqueID = effectComboBox:GetSelected()

        if (not effectUniqueID) then
          Schema.player.NotifyLocal("You must select an effect!")
          return
        end

        local parameters = self.parametersSelector:GetValue()

        if (editRow) then
          editRow:SetColumnData(1, effectUniqueID)
          editRow:SetColumnData(2, parameters)
        else
          effectsListView:AddFormattedLine(
            { effectUniqueID },
            { parameters, parameterFormatter }
          )
        end

        effectDialog:Close()

        self.hasUnsavedChanges = true
      end
    end

    effectsListView.DoDoubleClick = function(effectsListView, index, row)
      editEffect(row)
    end

    effectsListView.OnRowRightClick = function(effectsListView, index, row)
      local menu = DermaMenu()

      menu:AddOption("Edit", function()
        editEffect(row)
      end)

      menu:AddOption("Remove", function()
        effectsListView:RemoveLine(row:GetID())

        self.hasUnsavedChanges = true
      end)

      menu:Open()
    end

    addEffectButton.DoClick = function(addEffectButton)
      editEffect()
    end

    return effectsPanel, effectsListView
  end

  --- Sets up interactions elements.
  function PANEL:InitInteractionSets()
    local viewInteractionsForm = vgui.Create("expForm")
    viewInteractionsForm:SetCollapsible(false)
    viewInteractionsForm:SetPadding(4)
    viewInteractionsForm:SetName("View Interaction Sets")

    self.interactionSetsPanel:AddItem(viewInteractionsForm)

    -- Create the main interaction sets list
    self.interactionSetsListView = vgui.Create("expListView", self)
    self.interactionSetsListView:SetTall(128)
    self.interactionSetsListView:SetSortable(false)
    self.interactionSetsListView:SetMultiSelect(false)
    self.interactionSetsListView:AddColumn("UniqueID")
    self.interactionSetsListView:AddColumn("Conditions")
    self.interactionSetsListView:AddColumn("Amount of Interactions")

    viewInteractionsForm:AddItem(self.interactionSetsListView)

    local editInteractionSetForm = vgui.Create("expForm")
    editInteractionSetForm:SetPadding(4)
    editInteractionSetForm:SetName("Add Interaction Set")
    editInteractionSetForm:SetExpanded(false)

    self.interactionSetsPanel:AddItem(editInteractionSetForm)

    local uniqueIDTextEntry = editInteractionSetForm:TextEntry("UniqueID")

    function uniqueIDTextEntry.OnChange(uniqueIDTextEntry)
      self.hasUnsavedChanges = true
    end

    local interactionPropertySheet = vgui.Create("DPropertySheet")
    interactionPropertySheet:Dock(TOP)
    interactionPropertySheet:SetTall(256)
    editInteractionSetForm:AddItem(interactionPropertySheet)

    --[[
			Interaction Set Interactions
		--]]

    local interactionsPanel = vgui.Create("DPanelList")
    interactionsPanel:SetPadding(2)
    interactionsPanel:SetSpacing(4)

    interactionPropertySheet:AddSheet(
      "Interactions",
      interactionsPanel,
      "icon16/comments.png",
      nil,
      nil,
      "Set the interactions for this interaction set."
    )

    local interactionControlsPanel = vgui.Create("DPanel")
    interactionControlsPanel:Dock(TOP)
    interactionControlsPanel:DockMargin(4, 4, 4, 4)
    interactionControlsPanel:SetTall(22)

    local addInteractionButton = vgui.Create("DButton", interactionControlsPanel)
    addInteractionButton:SetText("Add Interaction")
    addInteractionButton:Dock(LEFT)
    addInteractionButton:SetWide(100)

    local moveUpButton = vgui.Create("DButton", interactionControlsPanel)
    moveUpButton:SetText("▲")
    moveUpButton:Dock(LEFT)
    moveUpButton:DockMargin(4, 0, 0, 0)
    moveUpButton:SetWide(32)

    local moveDownButton = vgui.Create("DButton", interactionControlsPanel)
    moveDownButton:SetText("▼")
    moveDownButton:Dock(LEFT)
    moveDownButton:DockMargin(4, 0, 0, 0)
    moveDownButton:SetWide(32)

    interactionsPanel:AddItem(interactionControlsPanel)

    local interactionsListView = vgui.Create("expListView")
    interactionsListView:SetMultiSelect(false)
    interactionsListView:SetSortable(false)
    interactionsListView:SetTall(interactionPropertySheet:GetTall() - 80)
    interactionsListView:AddColumn("UniqueID")
    interactionsListView:AddColumn("Text")
    interactionsListView:AddColumn("Amount of Responses")
    interactionsListView:AddColumn("Amount of Conditions")
    interactionsListView:AddColumn("Amount of Effects")

    interactionsPanel:AddItem(interactionsListView)

    local function getAllInteractions()
      local interactions = {}

      for _, row in pairs(interactionsListView:GetLines()) do
        table.insert(interactions, {
          uniqueID = row:GetColumnData(1),
          text = row:GetColumnData(2),
          responses = row:GetColumnData(3),
          conditions = row:GetColumnData(4),
          effects = row:GetColumnData(5),
        })
      end

      return interactions
    end

    local function openInteractionEditDialog(editRow)
      local uniqueID = editRow and editRow:GetColumnData(1)
      local text = editRow and editRow:GetColumnData(2)
      local responses = editRow and editRow:GetColumnData(3)
      local conditions = editRow and editRow:GetColumnData(4)
      local effects = editRow and editRow:GetColumnData(5) or {}
      local title = editRow and "Edit Interaction" or "Add Interaction"

      local dialog = vgui.Create("DFrame")
      dialog:SetAlwaysOnTop()
      dialog:SetTitle(title)
      dialog:SetSize(400, 400)
      dialog:Center()
      dialog:MakePopup()
      dialog:SetToRemoveOnceInvalid(interactionsListView)

      local uniqueIDParent = vgui.Create("expLabeledPanel", dialog)
      uniqueIDParent:SetLabel("UniqueID")
      uniqueIDParent:Dock(TOP)
      uniqueIDParent:DockMargin(4, 4, 4, 4)

      local uniqueIDTextEntry = vgui.Create("DTextEntry")
      uniqueIDTextEntry:SetAllowNonAsciiCharacters(true)
      uniqueIDTextEntry:SetDrawLanguageID(false)
      uniqueIDParent:SetPanel(uniqueIDTextEntry)

      if (uniqueID) then
        uniqueIDTextEntry:SetValue(uniqueID)
      end

      local propertySheet = vgui.Create("DPropertySheet", dialog)
      propertySheet:Dock(FILL)

      --[[
				General
			--]]

      local scrollPanel = vgui.Create("DScrollPanel")
      scrollPanel:Dock(FILL)

      propertySheet:AddSheet(
        "General",
        scrollPanel,
        "icon16/wrench_orange.png",
        nil,
        nil,
        "Set the general properties for this interaction."
      )

      local interactionForm = vgui.Create("expForm", scrollPanel)
      interactionForm:SetIsHeadless(true)
      interactionForm:Dock(TOP)
      interactionForm:SetName(title)

      local textRichText = interactionForm:TextEntry("Text")
      textRichText:SetMultiline(true)
      textRichText:SetTall(50)

      if (text) then
        textRichText:SetText(text)
      end

      --[[
				Responses
			--]]

      local scrollPanel = vgui.Create("DScrollPanel")
      scrollPanel:DockMargin(
        6,
        6,
        6,
        6
      )
      scrollPanel:Dock(FILL)

      propertySheet:AddSheet(
        "Responses",
        scrollPanel,
        "icon16/comment.png",
        nil,
        nil,
        "Set the responses for this interaction."
      )

      local addResponseButton = vgui.Create("DButton", scrollPanel)
      addResponseButton:SetText("Add Response")
      addResponseButton:Dock(TOP)
      addResponseButton:DockMargin(4, 4, 4, 4)
      addResponseButton:SetText("Add Response")

      local responsesListView = vgui.Create("expListView", scrollPanel)
      responsesListView:Dock(TOP)
      responsesListView:DockMargin(4, 4, 4, 4)
      responsesListView:SetMultiSelect(false)
      responsesListView:SetSortable(false)
      responsesListView:SetTall(180)
      responsesListView:AddColumn("Response")
      responsesListView:AddColumn("Next Interaction")
      responsesListView:AddColumn("Amount of Conditions")
      responsesListView:AddColumn("Amount of Effects")

      if (responses) then
        for _, response in pairs(responses) do
          responsesListView:AddFormattedLine(
            { response.answer },
            { response.next },
            { response.conditions or {}, Schema.formatters.TableCounter },
            { response.effects or {}, Schema.formatters.TableCounter }
          )
        end
      end

      local function openResponseEditDialog(editResponseRow)
        local answer = editResponseRow and editResponseRow:GetColumnData(1)
        local nextUniqueID = editResponseRow and editResponseRow:GetColumnData(2)
        local conditions = editResponseRow and editResponseRow:GetColumnData(3)
        local effects = editResponseRow and editResponseRow:GetColumnData(4) or {}
        local title = editResponseRow and "Edit Response" or "Add Response"

        local responseDialog = vgui.Create("DFrame")
        responseDialog:SetAlwaysOnTop()
        responseDialog:SetTitle(title)
        responseDialog:SetSize(400, 400)
        responseDialog:MakePopup()
        responseDialog:SetToRemoveOnceInvalid(responsesListView)
        responseDialog:CenterHorizontal(0.6)
        responseDialog:CenterVertical(0.6)

        local propertySheet = vgui.Create("DPropertySheet", responseDialog)
        propertySheet:Dock(FILL)

        --[[
					General
				--]]

        local scrollPanel = vgui.Create("DScrollPanel")
        scrollPanel:Dock(FILL)

        propertySheet:AddSheet(
          "General",
          scrollPanel,
          "icon16/wrench_orange.png",
          nil,
          nil,
          "Set the general properties for this response."
        )

        local responseGeneralForm = vgui.Create("expForm", scrollPanel)
        responseGeneralForm:SetIsHeadless(true)
        responseGeneralForm:Dock(TOP)
        responseGeneralForm:SetName(title)

        local responseTextEntry = responseGeneralForm:TextEntry("Text")
        responseTextEntry:SetMultiline(true)
        responseTextEntry:SetTall(50)

        if (answer) then
          responseTextEntry:SetValue(answer)
        end

        local responseNextComboBox = responseGeneralForm:ComboBox("Next Interaction")
        responseNextComboBox:SetSortItems(false)
        responseNextComboBox:AddChoice("None", "", not nextUniqueID)

        -- Add all interaction uniqueID's
        for _, interaction in pairs(getAllInteractions()) do
          responseNextComboBox:AddChoice(interaction.uniqueID, interaction.uniqueID,
            nextUniqueID == interaction.uniqueID)
        end

        --[[
					Conditions
				--]]

        local conditionsScrollPanel = vgui.Create("DScrollPanel")
        conditionsScrollPanel:Dock(FILL)

        propertySheet:AddSheet(
          "Conditions",
          conditionsScrollPanel,
          "icon16/text_list_numbers.png",
          nil,
          nil,
          "Set the conditions for this response."
        )

        local responseConditionsForm = vgui.Create("expForm", conditionsScrollPanel)
        responseConditionsForm:SetIsHeadless(true)
        responseConditionsForm:Dock(TOP)
        responseConditionsForm:SetName(title)

        local conditionsPanel, responseConditionsListView = self:CreateConditionsPanel()
        conditionsPanel:SetTall(interactionPropertySheet:GetTall() - 80)

        responseConditionsForm:AddItem(conditionsPanel)

        responseConditionsListView:SetupWithData(conditions)

        --[[
					Effects to execute when this response is chosen
					(executed on `serverOnChoose` for the response)
				--]]

        local effectsScrollPanel = vgui.Create("DScrollPanel")
        effectsScrollPanel:DockMargin(
          6,
          6,
          6,
          6
        )
        effectsScrollPanel:Dock(FILL)

        propertySheet:AddSheet(
          "Effects",
          effectsScrollPanel,
          "icon16/bell.png",
          nil,
          nil,
          "Set the effects to execute when this response is chosen."
        )

        local infoLabel = vgui.Create("DLabel", effectsScrollPanel)
        infoLabel:Dock(TOP)
        infoLabel:DockMargin(4, 4, 4, 4)
        infoLabel:SetText(
          "Response effects are executed on the server when the response is chosen. For example, you can give the player an item, progress a quest/mission or print a message to the chat or console."
        )
        infoLabel:SetWrap(true)
        infoLabel:SetAutoStretchVertical(true)

        local effectsPanel, interactionEffectsListView = self:CreateEffectsPanel()
        effectsPanel:SetTall(interactionPropertySheet:GetTall() - 80)
        effectsPanel:SetParent(effectsScrollPanel)
        effectsPanel:Dock(TOP)

        interactionEffectsListView:SetupWithData(effects)

        --[[
					Save/Add button
				--]]

        local submitButton = vgui.Create("DButton", responseDialog)
        submitButton:SetText(editResponseRow and "Save" or "Add")
        submitButton:Dock(BOTTOM)

        submitButton.DoClick = function(submitButton)
          local responseText = responseTextEntry:GetValue():Trim()

          if (responseText == "") then
            Schema.player.NotifyLocal("You must enter text for the response!")
            return
          end

          local _, nextUniqueID = responseNextComboBox:GetSelected()
          local conditions = {}

          for _, line in pairs(responseConditionsListView:GetLines()) do
            table.insert(conditions, {
              uniqueID = line:GetColumnData(1),
              parameters = line:GetColumnData(2),
            })
          end

          local effects = {}

          for _, line in pairs(interactionEffectsListView:GetLines()) do
            table.insert(effects, {
              uniqueID = line:GetColumnData(1),
              parameters = line:GetColumnData(2),
            })
          end

          if (editResponseRow) then
            editResponseRow:SetColumnData(1, responseText)
            editResponseRow:SetColumnData(2, nextUniqueID)
            editResponseRow:SetColumnData(3, conditions)
            editResponseRow:SetColumnData(4, effects)
          else
            responsesListView:AddFormattedLine(
              { responseText },
              { nextUniqueID },
              { conditions, Schema.formatters.TableCounter },
              { effects, Schema.formatters.TableCounter }
            )
          end

          responseTextEntry:SetValue("")
          responseNextComboBox:SetValue("")
          clearListView(responseConditionsListView)

          self.hasUnsavedChanges = true

          responseDialog:Close()
        end
      end

      addResponseButton.DoClick = function(addResponseButton)
        openResponseEditDialog()
      end

      responsesListView.DoDoubleClick = function(responsesListView, index, row)
        openResponseEditDialog(row)
      end

      responsesListView.OnRowRightClick = function(responsesListView, index, row)
        local menu = DermaMenu()

        menu:AddOption("Edit", function()
          openResponseEditDialog(row)
        end)

        menu:AddOption("Remove", function()
          responsesListView:RemoveLine(row:GetID())

          self.hasUnsavedChanges = true
        end)

        menu:Open()
      end

      --[[
				Conditions
			--]]

      local conditionsScrollPanel = vgui.Create("DScrollPanel")
      conditionsScrollPanel:Dock(FILL)

      propertySheet:AddSheet(
        "Conditions",
        conditionsScrollPanel,
        "icon16/text_list_numbers.png",
        nil,
        nil,
        "Set the conditions for this response."
      )

      local conditionsForm = vgui.Create("expForm", conditionsScrollPanel)
      conditionsForm:SetIsHeadless(true)
      conditionsForm:Dock(TOP)
      conditionsForm:SetName(title)

      local conditionsPanel, interactionConditionsListView = self:CreateConditionsPanel()
      conditionsPanel:SetTall(interactionPropertySheet:GetTall() - 80)

      conditionsForm:AddItem(conditionsPanel)

      interactionConditionsListView:SetupWithData(conditions)

      --[[
				Effects to execute when this interaction starts
				(executed on `serverOnStart` for the interaction)
			--]]

      local effectsScrollPanel = vgui.Create("DScrollPanel")
      effectsScrollPanel:DockMargin(
        6,
        6,
        6,
        6
      )
      effectsScrollPanel:Dock(FILL)

      propertySheet:AddSheet(
        "Effects",
        effectsScrollPanel,
        "icon16/bell.png",
        nil,
        nil,
        "Set the effects to execute when this interaction starts."
      )

      local infoLabel = vgui.Create("DLabel", effectsScrollPanel)
      infoLabel:Dock(TOP)
      infoLabel:DockMargin(4, 4, 4, 4)
      infoLabel:SetText(
        "Interaction effects are executed on the server when the interaction starts. For example, you can give the player an item, progress a quest/mission or print a message to the chat or console."
      )
      infoLabel:SetWrap(true)
      infoLabel:SetAutoStretchVertical(true)

      local effectsPanel, interactionEffectsListView = self:CreateEffectsPanel()
      effectsPanel:SetTall(interactionPropertySheet:GetTall() - 80)
      effectsPanel:SetParent(effectsScrollPanel)
      effectsPanel:Dock(TOP)

      interactionEffectsListView:SetupWithData(effects)

      --[[
				Save/Add button
			--]]

      local submitButton = vgui.Create("DButton", dialog)
      submitButton:Dock(BOTTOM)
      submitButton:SetText(editRow and "Save" or "Add")

      submitButton.DoClick = function(submitButton)
        local uniqueID = uniqueIDTextEntry:GetValue():Trim()

        if (uniqueID == "") then
          Schema.player.NotifyLocal("You must enter a UniqueID for the interaction!")
          return
        end

        local text = textRichText:GetValue():Trim()

        if (text == "") then
          Schema.player.NotifyLocal("You must enter text for the interaction!")
          return
        end

        local responses = {}

        for _, line in pairs(responsesListView:GetLines()) do
          local next = line:GetColumnData(2)

          table.insert(responses, {
            answer = line:GetColumnData(1),
            next = next ~= "" and next or nil,
            conditions = line:GetColumnData(3),
            effects = line:GetColumnData(4),
          })
        end

        local conditions = {}

        for _, line in pairs(interactionConditionsListView:GetLines()) do
          table.insert(conditions, {
            uniqueID = line:GetColumnData(1),
            parameters = line:GetColumnData(2),
          })
        end

        local effects = {}

        for _, line in pairs(interactionEffectsListView:GetLines()) do
          table.insert(effects, {
            uniqueID = line:GetColumnData(1),
            parameters = line:GetColumnData(2),
          })
        end

        if (editRow) then
          editRow:SetColumnData(1, uniqueID)
          editRow:SetColumnData(2, text)
          editRow:SetColumnData(3, responses)
          editRow:SetColumnData(4, conditions)
          editRow:SetColumnData(5, effects)
        else
          interactionsListView:AddFormattedLine(
            { uniqueID },
            { text },
            { responses, Schema.formatters.TableCounter },
            { conditions, Schema.formatters.TableCounter },
            { effects, Schema.formatters.TableCounter }
          )
        end

        uniqueIDTextEntry:SetValue("")
        textRichText:SetText("")
        clearListView(responsesListView)

        self.hasUnsavedChanges = true

        dialog:Close()
      end
    end

    interactionsListView.DoDoubleClick = function(interactionsListView, index, row)
      openInteractionEditDialog(row)
    end

    interactionsListView.OnRowRightClick = function(interactionsListView, index, row)
      local menu = DermaMenu()

      menu:AddOption("Edit", function()
        openInteractionEditDialog(row)
      end)

      menu:AddOption("Remove", function()
        interactionsListView:RemoveLine(row:GetID())

        self.hasUnsavedChanges = true
      end)

      menu:Open()
    end

    --[[
			Interaction Set Conditions
		--]]

    local conditionsPanel, conditionsListView = self:CreateConditionsPanel()
    conditionsPanel:SetTall(interactionPropertySheet:GetTall() - 80)

    interactionPropertySheet:AddSheet(
      "Conditions",
      conditionsPanel,
      "icon16/text_list_numbers.png",
      nil,
      nil,
      "Set the conditions for this interaction set."
    )

    --[[
			Interaction Set Edit/Submit controls
		--]]

    local submitButton = vgui.Create("DButton")
    submitButton:SetText("Add")

    editInteractionSetForm:AddItem(submitButton)

    local cancelEditButton = vgui.Create("DButton")
    cancelEditButton:SetText("Cancel")
    cancelEditButton:SetVisible(false)

    editInteractionSetForm:AddItem(cancelEditButton)

    local function setEdit(row)
      self.isEdittingInteractionSet = row

      if (row) then
        uniqueIDTextEntry:SetValue(row:GetColumnData(1))
        clearListView(conditionsListView)
        clearListView(interactionsListView)

        local conditions = row:GetColumnData(2)
        local interactions = row:GetColumnData(3)

        conditionsListView:SetupWithData(conditions)

        for _, interaction in pairs(interactions) do
          interactionsListView:AddFormattedLine(
            { interaction.uniqueID },
            { interaction.text },
            { interaction.responses, Schema.formatters.TableCounter },
            { interaction.conditions or {}, Schema.formatters.TableCounter },
            { interaction.effects or {}, Schema.formatters.TableCounter }
          )
        end

        editInteractionSetForm:SetName("Edit Interaction Set")
        submitButton:SetText("Save")
        cancelEditButton:SetVisible(true)
        editInteractionSetForm:SetExpanded(true)
      else
        uniqueIDTextEntry:SetValue("")
        clearListView(conditionsListView)
        clearListView(interactionsListView)

        editInteractionSetForm:SetName("Add Interaction Set")
        submitButton:SetText("Add")
        cancelEditButton:SetVisible(false)
        editInteractionSetForm:SetExpanded(false)
      end
    end

    cancelEditButton.DoClick = function(cancelEditButton)
      setEdit(nil)
    end

    submitButton.DoClick = function(submitButton)
      local uniqueID = uniqueIDTextEntry:GetValue():Trim()

      if (uniqueID == "") then
        Schema.player.NotifyLocal("You must enter a UniqueID for the interaction set!")
        return
      end

      local conditions = {}
      local interactions = {}

      for _, line in pairs(conditionsListView:GetLines()) do
        table.insert(conditions, {
          uniqueID = line:GetColumnData(1),
          parameters = line:GetColumnData(2),
        })
      end

      for _, line in pairs(interactionsListView:GetLines()) do
        table.insert(interactions, {
          uniqueID = line:GetColumnData(1),
          text = line:GetColumnData(2),
          responses = line:GetColumnData(3),
          conditions = line:GetColumnData(4),
          effects = line:GetColumnData(5),
        })
      end

      if (self.isEdittingInteractionSet) then
        self.isEdittingInteractionSet:SetColumnData(1, uniqueID)
        self.isEdittingInteractionSet:SetColumnData(2, conditions)
        self.isEdittingInteractionSet:SetColumnData(3, interactions)
        setEdit(nil)
      else
        self.interactionSetsListView:AddFormattedLine(
          { uniqueID },
          { conditions, Schema.formatters.TableCounter },
          { interactions, Schema.formatters.TableCounter }
        )
      end

      uniqueIDTextEntry:SetValue("")
      clearListView(conditionsListView)
      clearListView(interactionsListView)

      self.hasUnsavedChanges = true
    end

    self.interactionSetsListView.OnRowSelected = function(interactionSetsListView, index, row)
      setEdit(row)
    end

    self.interactionSetsListView.OnRowRightClick = function(interactionSetsListView, index, row)
      local menu = DermaMenu()

      menu:AddOption("Remove", function()
        if (self.isEdittingInteractionSet == row) then
          setEdit(nil)
        end

        interactionSetsListView:RemoveLine(row:GetID())

        self.hasUnsavedChanges = true
      end)

      menu:Open()
    end

    moveUpButton.DoClick = function(moveUpButton)
      local selectedLine = interactionsListView:GetSelectedLine()

      if (not selectedLine or selectedLine <= 1) then
        return
      end

      local currentLine = interactionsListView:GetLine(selectedLine)
      local previousLine = interactionsListView:GetLine(selectedLine - 1)

      local maxColumns = #currentLine.Columns

      for i = 1, maxColumns do
        local currentText = currentLine:GetColumnData(i)
        local previousText = previousLine:GetColumnData(i)

        currentLine:SetColumnData(i, previousText)
        previousLine:SetColumnData(i, currentText)
      end

      interactionsListView:ClearSelection()
      interactionsListView:SelectItem(previousLine)

      self.hasUnsavedChanges = true
    end

    moveDownButton.DoClick = function(moveDownButton)
      local selectedLine = interactionsListView:GetSelectedLine()

      if (not selectedLine or selectedLine >= #interactionsListView:GetLines()) then
        return
      end

      local currentLine = interactionsListView:GetLine(selectedLine)
      local nextLine = interactionsListView:GetLine(selectedLine + 1)

      local maxColumns = #currentLine.Columns

      for i = 1, maxColumns do
        local currentText = currentLine:GetColumnData(i)
        local nextText = nextLine:GetColumnData(i)

        currentLine:SetColumnData(i, nextText)
        nextLine:SetColumnData(i, currentText)
      end

      interactionsListView:ClearSelection()
      interactionsListView:SelectItem(nextLine)

      self.hasUnsavedChanges = true
    end

    addInteractionButton.DoClick = function(addInteractionButton)
      openInteractionEditDialog()
    end
  end

  --- Find the spawnicon and click it
  function PANEL:SelectModel(model)
    for _, panel in pairs(self.modelItemsList:GetItems()) do
      if (panel:GetModelName() == model) then
        panel:DoClick()
        break
      end
    end
  end

  --- Gets the currently set interactions sets.
  --- @return table
  function PANEL:GetInteractionSets()
    local interactionSets = {}

    for _, line in pairs(self.interactionSetsListView:GetLines()) do
      table.insert(interactionSets, {
        uniqueID = line:GetColumnData(1),
        conditions = line:GetColumnData(2),
        interactions = line:GetColumnData(3),
      })
    end

    return interactionSets
  end

  --- Sets the NPC to edit, filling in the form with the data.
  --- @param npcToEdit Entity The NPC to edit.
  --- @param npcData table The NPC data.
  function PANEL:SetNpcToEdit(npcToEdit, npcData)
    self.npcData = npcData
    self.npcToEdit = npcToEdit

    self.uniqueIDTextEntry:SetValue(npcData.uniqueID)
    self.nameTextEntry:SetValue(npcData.name)
    self.descriptionTextEntry:SetValue(npcData.description)
    self.voicePitchSlider:SetValue(npcData.voicePitch or 0)
    self:SelectModel(npcData.model)

    if (npcData.interactionSets) then
      for _, interactionSet in pairs(npcData.interactionSets) do
        self.interactionSetsListView:AddFormattedLine(
          { interactionSet.uniqueID },
          { interactionSet.conditions, Schema.formatters.TableCounter },
          { interactionSet.interactions, Schema.formatters.TableCounter }
        )
      end
    end

    self.interactionSetsSheet.Tab:SetEnabled(true)
    self.interactionSetsSheet.Tab:SetAlpha(255)

    self:SetTitle("Editing '" .. tostring(npcData.name) .. "'")

    self.hasUnsavedChanges = false
  end

  --- Submits the form data.
  function PANEL:Submit()
    local name = self.nameTextEntry:GetValue():Trim()
    local model = self.modelTextEntry:GetValue():Trim()
    local description = self.descriptionTextEntry:GetValue():Trim()
    local uniqueID = self.uniqueIDTextEntry:GetValue():Trim()
    local voicePitch = self.voicePitchSlider:GetValue()
    local interactionSets = self:GetInteractionSets()

    if (uniqueID == "") then
      Schema.player.NotifyLocal("You must enter a unique ID for the NPC!")
      return
    end

    if (name == "") then
      Schema.player.NotifyLocal("You must enter a name for the NPC!")
      return
    end

    if (description == "") then
      Schema.player.NotifyLocal("You must enter a description for the NPC!")
      return
    end

    if (model == "") then
      Schema.player.NotifyLocal("You must enter a model for the NPC!")
      return
    end

    -- Check that the model is valid.
    if (not util.IsValidModel(model)) then
      Schema.player.NotifyLocal("The model you entered is not valid!")
      return
    end

    self.submitButton:SetEnabled(false)

    local data = {
      entityIndex = self.npcToEdit and self.npcToEdit:EntIndex() or 0,
      uniqueID = uniqueID,
      name = name,
      description = description,
      model = model,
      voicePitch = voicePitch,
      interactionSets = interactionSets,
    }
    Schema.chunkedNetwork.Send("NpcEdit", data)

    self.hasUnsavedChanges = false

    -- If the panel still exists, re-enable the submit button in case of a failure.
    timer.Simple(1, function()
      if (IsValid(self)) then
        self.submitButton:SetEnabled(true)
      end
    end)
  end

  --- Called when the layout should be performed.
  function PANEL:PerformLayout(width, height)
    self.lblTitle:SizeToContents()

    self.interactionSetsPanel:StretchToParent(4, 28, 4, 4)
    self.settingsPanel:StretchToParent(4, 28, 4, 4)
    self.propertySheet:StretchToParent(4, 28, 4, 4)

    self.btnClose:SetWide(20)
    self.btnClose:SetPos(self:GetWide() - self.btnClose:GetWide() - 5, 2)

    self.modelItemsList:SizeToChildren(false, true)

    derma.SkinHook("Layout", "Frame", self)
  end

  vgui.Register("expNpcEditor", PANEL, "DFrame")
end

concommand.Add("exp_toggle_npc_inline_editor", Schema.npc.ToggleInlineEditor)
