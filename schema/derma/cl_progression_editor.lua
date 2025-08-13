--- @alias ProgressionForEdit.IsInProgressInfo { type: string, value: string }
--- @alias ProgressionForEdit.Goal { key: string, name: string, type: string, getProgressScript: string }
--- @alias ProgressionForEdit { uniqueID: string, scope: string, name: string, completedKey: string, isInProgressInfo: ProgressionForEdit.IsInProgressInfo, progressionKeys: ProgressionKey[] }

--- Clears a listview, removing all items.
--- @param listView DListView
local function clearListView(listView)
  for _, line in pairs(listView:GetLines()) do
    listView:RemoveLine(line:GetID())
  end
end

local function isInProgressFormatter(value)
  return ("`%s` (%s)"):format(value.value, value.type)
end

do
  --- @class expProgressionsEditor : DFrame
  local PANEL = {}

  --- Called when the panel is initialized.
  function PANEL:Init()
    self:SetTitle("Progressions Editor")

    local panelList = vgui.Create("DPanelList", self)
    panelList:Dock(FILL)
    panelList:SetPadding(4)
    panelList:SetSpacing(4)
    panelList:EnableVerticalScrollbar()

    local progressionListForm = vgui.Create("expForm", panelList)
    progressionListForm:Dock(TOP)
    progressionListForm:SetPadding(2)
    progressionListForm:SetSpacing(4)
    progressionListForm:SetName("Progression Trackers")
    panelList:AddItem(progressionListForm)

    self.progressionsListView = vgui.Create("expListView", panelList)
    self.progressionsListView:Dock(TOP)
    self.progressionsListView:SetTall(ScrH() * .25)
    self.progressionsListView:SetMultiSelect(false)
    self.progressionsListView:AddColumn("ID")
    self.progressionsListView:AddColumn("Scope")
    self.progressionsListView:AddColumn("Name")
    self.progressionsListView:AddColumn("Completed Key")
    self.progressionsListView:AddColumn("In Progress")
    self.progressionsListView:AddColumn("Progression Keys")
    self.progressionsListView:AddColumn("Goals")
    progressionListForm:AddItem(self.progressionsListView)

    local progressionEditForm = vgui.Create("expProgressionEditorForm", self)
    progressionEditForm:Dock(TOP)
    panelList:AddItem(progressionEditForm)

    local function setEdit(row)
      self.isEdittingRow = row

      if (row) then
        local uniqueID = row:GetColumnData(1)
        local scope = row:GetColumnData(2)
        local name = row:GetColumnData(3)
        local completedKey = row:GetColumnData(4)
        local isInProgressInfo = row:GetColumnData(5)
        local progressionKeys = row:GetColumnData(6)
        local goals = row:GetColumnData(7)

        progressionEditForm:LoadProgression({
          uniqueID = uniqueID,
          scope = scope,
          name = name,
          completedKey = completedKey,
          isInProgressInfo = isInProgressInfo,
          progressionKeys = progressionKeys,
          goals = goals,
        })
      else
        progressionEditForm:ClearProgression()
      end

      progressionEditForm:SetName(row and "Edit Progression" or "Add Progression")
      progressionEditForm:SetExpanded(row ~= nil)

      progressionEditForm:InvalidateLayout(true)
      panelList:InvalidateLayout(true)
    end

    progressionEditForm.OnSave = function(
        progressionEditForm,
        uniqueID,
        scope,
        name,
        completedKey,
        isInProgressInfo,
        progressionKeys,
        goals
    )
      if (self.isEdittingRow) then
        self.isEdittingRow:SetColumnData(1, uniqueID)
        self.isEdittingRow:SetColumnData(2, scope)
        self.isEdittingRow:SetColumnData(3, name)
        self.isEdittingRow:SetColumnData(4, completedKey)
        self.isEdittingRow:SetColumnData(5, isInProgressInfo)
        self.isEdittingRow:SetColumnData(6, progressionKeys)
        self.isEdittingRow:SetColumnData(7, goals)

        setEdit(nil)
      else
        self.progressionsListView:AddFormattedLine(
          { uniqueID },
          { scope },
          { name },
          { completedKey },
          { isInProgressInfo, isInProgressFormatter },
          { progressionKeys, Schema.formatters.TableCounter },
          { goals, Schema.formatters.TableCounter }
        )
      end

      setEdit(nil)
    end

    progressionEditForm.OnCancel = function()
      setEdit(nil)
    end

    self.progressionsListView.OnRowSelected = function(_, _, line)
      setEdit(line)
    end

    self.progressionsListView.OnRowRightClick = function(_, _, line)
      local menu = DermaMenu()

      menu:AddOption("Remove", function()
        if (self.isEdittingRow == line) then
          setEdit(nil)
        end

        self.progressionsListView:RemoveLine(line:GetID())
      end)

      menu:Open()
    end

    self.submitButton = vgui.Create("DButton", self)
    self.submitButton:SetText("Save Progressions")
    self.submitButton:Dock(BOTTOM)
    self.submitButton:SetTall(32)
    self.submitButton.DoClick = function()
      self:Submit()
    end

    self:InvalidateLayout()
  end

  --- Submits the progression data to the server.
  function PANEL:Submit()
    local originalProgressions = self.originalProgressions
    local changedProgressions = {}
    local progressions = {}

    for _, line in pairs(self.progressionsListView:GetLines()) do
      local uniqueID = line:GetColumnText(1)
      local scope = line:GetColumnText(2)
      local name = line:GetColumnText(3)
      local completedKey = line:GetColumnText(4)
      local isInProgressInfo = line:GetColumnData(5)
      local progressionKeys = line:GetColumnData(6)
      local goals = line:GetColumnData(7)
      local progression = {
        uniqueID = uniqueID,
        scope = scope,
        name = name,
        completedKey = completedKey,
        isInProgressInfo = isInProgressInfo,
        progressionKeys = progressionKeys,
        goals = goals,
      }

      table.insert(progressions, progression)

      -- Check if the progression has been changed.
      local originalProgression = originalProgressions[uniqueID]

      if (not originalProgression) then
        table.insert(changedProgressions, progression)
        continue
      end

      if (
            originalProgression.name ~= name
            or originalProgression.scope ~= scope
            or originalProgression.completedKey ~= completedKey
            or originalProgression.isInProgressInfo ~= isInProgressInfo
          ) then
        table.insert(changedProgressions, progression)
        continue
      end

      local originalProgressionKeys = originalProgression.progressionKeys

      -- Check if the progressionKeys have been changed.
      local progressionKeysChanged = false

      for _, progressionKey in pairs(progressionKeys) do
        local originalProgressionKey = originalProgressionKeys[progressionKey.key]

        if (not originalProgressionKey or originalProgressionKey.type ~= progressionKey.type) then
          progressionKeysChanged = true
          break
        end
      end

      if (progressionKeysChanged) then
        table.insert(changedProgressions, progression)
        continue
      end

      -- Check if the goals have been changed.
      local originalGoals = originalProgression.goals

      for _, goal in pairs(goals) do
        local originalGoal = originalGoals[goal.key]

        if (
              not originalGoal
              or originalGoal.name ~= goal.name
              or originalGoal.type ~= goal.type
              or originalGoal.getProgressScript ~= goal.getProgressScript
            ) then
          table.insert(changedProgressions, progression)
          break
        end
      end
    end

    -- Find any progressions that have been removed.
    for uniqueID, originalProgression in pairs(originalProgressions) do
      local found = false

      for _, progression in pairs(progressions) do
        if (progression.uniqueID == uniqueID) then
          found = true
          break
        end
      end

      if (not found) then
        net.Start("expProgressionRemove")
        net.WriteString(uniqueID)
        net.SendToServer()
      end
    end

    -- Send the changed progressions to the server.
    self.submitButton:SetEnabled(false)

    for _, changedProgression in pairs(changedProgressions) do
      Schema.chunkedNetwork.Send("ProgressionEdit", changedProgression)
    end

    self.hasUnsavedChanges = false

    -- If the panel still exists, re-enable the submit button in case of a failure.
    timer.Simple(1, function()
      if (IsValid(self)) then
        self.submitButton:SetEnabled(true)
      end
    end)
  end

  --- Sets the progressions for the editor.
  function PANEL:LoadProgressions(progressions)
    self.originalProgressions = {}
    self.progressionsListView:Clear()

    for _, progression in pairs(progressions) do
      self.progressionsListView:AddFormattedLine(
        { progression.uniqueID },
        { progression.scope },
        { progression.name },
        { progression.completedKey },
        { progression.isInProgressInfo, isInProgressFormatter },
        { progression.progressionKeys, Schema.formatters.TableCounter },
        { progression.goals, Schema.formatters.TableCounter }
      )

      self.originalProgressions[progression.uniqueID] = progression
    end
  end

  vgui.Register("expProgressionsEditor", PANEL, "DFrame")
end

do
  --- @class expProgressionEditorForm : expForm
  local PANEL = {}

  DEFINE_BASECLASS("expForm")

  function PANEL:Init()
    self:SetPadding(2)
    self:SetSpacing(4)
    self:SetName("Add Progression")
    self:SetExpanded(false)

    self.templateComboBox = self:ComboBox("Template")
    self.templateComboBox:SetSortItems(false)

    self.propertySheet = vgui.Create("DPropertySheet", self)
    self.propertySheet:SetTall(ScrH() * .4)
    self:AddItem(self.propertySheet)

    --[[
			General settings
		--]]

    local generalPanel = vgui.Create("DScrollPanel")
    generalPanel:SetPadding(2)
    generalPanel:SizeToContents()

    self.propertySheet:AddSheet(
      "General",
      generalPanel,
      "icon16/cog.png",
      nil,
      nil,
      "Edit general progression settings."
    )

    local progressionGeneralForm = vgui.Create("expForm", generalPanel)
    progressionGeneralForm:SetName("General Settings")
    progressionGeneralForm:Dock(TOP)
    progressionGeneralForm:SetIsHeadless(true)

    self.uniqueIdTextEntry = progressionGeneralForm:TextEntry("Unique ID")
    self.scopeTextEntry = progressionGeneralForm:TextEntry("Scope")
    self.nameTextEntry = progressionGeneralForm:TextEntry("Name")

    self.completedKeyDropdown = progressionGeneralForm:ComboBox("Completed Key")
    self.isInProgressDropdown = progressionGeneralForm:ComboBox("Is In Progress")
    self.isInProgressDropdown:SetSortItems(false)
    self.isInProgressDropdown:AddChoice("Lua:", "lua")
    self.isInProgressDropdown:AddChoice("Key:", "key")

    self.isInProgressValueDropdown = progressionGeneralForm:ComboBox("")
    self.isInProgressValueTextEntry = progressionGeneralForm:TextEntry("")
    self.isInProgressValueTextEntry:SetMultiline(true)
    self.isInProgressValueTextEntry:SetTall(32)
    self.isInProgressDropdown.OnSelect = function(_, _, value, data)
      local showTextEntry = data == "lua"

      self.isInProgressValueDropdown:GetParent():SetVisible(not showTextEntry)
      self.isInProgressValueTextEntry:GetParent():SetVisible(showTextEntry)
    end
    self.isInProgressDropdown:ChooseOptionID(1)

    --[[
			Setup Goals for the progression.
		--]]

    local goalsPanel = vgui.Create("DScrollPanel")
    goalsPanel:SetPadding(2)
    goalsPanel:SizeToContents()

    self.propertySheet:AddSheet(
      "Goals",
      goalsPanel,
      "icon16/flag_green.png",
      nil,
      nil,
      "Edit progression goals."
    )

    local goalsForm = vgui.Create("expForm", goalsPanel)
    goalsForm:SetName("Goals")
    goalsForm:Dock(FILL)
    goalsForm:SetIsHeadless(true)

    local infoLabel = vgui.Create("DLabel")
    infoLabel:SetText(
      "Goals are visible to the player and are used to track progression. For example a goal could be 'Kill 10 enemies', which would be incremented each time the player kills an enemy."
    )
    infoLabel:SetWrap(true)
    infoLabel:SetAutoStretchVertical(true)
    infoLabel:SizeToContents()
    infoLabel:Dock(TOP)
    goalsForm:AddItem(infoLabel)

    self.progressionGoalsListView = vgui.Create("expListView", self)
    self.progressionGoalsListView:Dock(TOP)
    self.progressionGoalsListView:SetTall(150)
    self.progressionGoalsListView:SetMultiSelect(false)
    self.progressionGoalsListView:AddColumn("Key")
    self.progressionGoalsListView:AddColumn("Name")
    self.progressionGoalsListView:AddColumn("Type")
    self.progressionGoalsListView:AddColumn("GetProgress (Lua)")
    goalsForm:AddItem(self.progressionGoalsListView)

    local function openProgressionGoalEditDialog(editRow)
      local key = editRow and editRow:GetColumnText(1)
      local name = editRow and editRow:GetColumnText(2)
      local type = editRow and editRow:GetColumnText(3)
      local getProgressScript = editRow and editRow:GetColumnText(4)
      local title = editRow and "Edit Progression Goal" or "Add Progression Goal"

      local dialog = vgui.Create("DFrame")
      dialog:SetAlwaysOnTop()
      dialog:SetTitle(title)
      dialog:SetSize(600, 400)
      dialog:Center()
      dialog:MakePopup()
      dialog:SetToRemoveOnceInvalid(self)

      local scrollPanel = vgui.Create("DScrollPanel", dialog)
      scrollPanel:Dock(FILL)

      local progressionGoalForm = vgui.Create("expForm", scrollPanel)
      progressionGoalForm:SetCollapsible(false)
      progressionGoalForm:Dock(TOP)
      progressionGoalForm:SetName(title)

      local keyTextEntry = progressionGoalForm:TextEntry("Key")

      if (key) then
        keyTextEntry:SetValue(key)
      end

      local nameTextEntry = progressionGoalForm:TextEntry("Name")

      if (name) then
        nameTextEntry:SetValue(name)
      end

      local typeComboBox = progressionGoalForm:ComboBox("Type")
      typeComboBox:SetSortItems(false)
      typeComboBox:AddChoice("Boolean", "boolean", type == "boolean")
      typeComboBox:AddChoice("Number", "number", type == "number")

      local getProgressTextEntry = progressionGoalForm:TextEntry("GetProgress (Lua)")
      getProgressTextEntry:SetPlaceholderText("return progression / 100, 100, progression")
      getProgressTextEntry:SetMultiline(true)
      getProgressTextEntry:SetDrawLanguageID(false)
      getProgressTextEntry:SetTall(64)

      if (getProgressScript) then
        getProgressTextEntry:SetValue(getProgressScript)
      end

      local hintLabel = vgui.Create("DLabel")
      hintLabel:SetText(
        "Return the progress of the goal in three values: \n"
        ..
        "- The progress as a fraction (0 to 1) for a progress bar, e.g: 0.25 for 25% complete. Or a boolean (true/false) for a checkmark. \n"
        .. "- The maximum progress value, e.g: 100 for 100 kills. (Leave nil if the goal is boolean) \n"
        .. "- The current progress value, e.g: 25 for 25 kills. (Leave nil if the goal is boolean) \n"
        .. "\n"
        .. "Some variables are available to you:\n"
        .. "- `progression` contains the current value of the progression key.\n"
        .. "- `player` contains the player the progression is for.\n"
      )
      hintLabel:SetAlpha(128)
      hintLabel:SetWrap(true)
      hintLabel:SetAutoStretchVertical(true)
      progressionGoalForm:AddItem(hintLabel)

      local submitButton = vgui.Create("DButton", dialog)
      submitButton:SetText(editRow and "Save" or "Add")
      submitButton:Dock(BOTTOM)

      submitButton.DoClick = function(submitButton)
        local key = keyTextEntry:GetValue():Trim()
        local name = nameTextEntry:GetValue():Trim()
        local _, type = typeComboBox:GetSelected()
        local getProgressScript = getProgressTextEntry:GetValue():Trim()

        if (key == "") then
          Schema.player.NotifyLocal("You must enter a key for the progression goal!")
          return
        end

        if (name == "") then
          Schema.player.NotifyLocal("You must enter a name for the progression goal!")
          return
        end

        if (type == "") then
          Schema.player.NotifyLocal("You must select a type for the progression goal!")
          return
        end

        if (getProgressScript == "") then
          Schema.player.NotifyLocal("You must enter a lua expression for the progression goal!")
          return
        end

        if (editRow) then
          editRow:SetColumnText(1, key)
          editRow:SetColumnText(2, name)
          editRow:SetColumnText(3, type)
          editRow:SetColumnText(4, getProgressScript)
        else
          self:AddProgressionGoal(key, name, type, getProgressScript)
        end

        keyTextEntry:SetValue("")
        nameTextEntry:SetValue("")
        typeComboBox:SetValue("")
        getProgressTextEntry:SetValue("")
        dialog:Close()
      end
    end

    self.progressionGoalsListView.DoDoubleClick = function(_, _, row)
      openProgressionGoalEditDialog(row)
    end

    self.addProgressionGoalButton = vgui.Create("DButton", self)
    self.addProgressionGoalButton:SetText("Add Progression Goal")
    self.addProgressionGoalButton:Dock(BOTTOM)
    self.addProgressionGoalButton.DoClick = function()
      openProgressionGoalEditDialog()
    end
    goalsForm:AddItem(self.addProgressionGoalButton)

    --[[
			Progression Keys
		--]]

    local progressionKeysPanel = vgui.Create("DScrollPanel")
    progressionKeysPanel:SetPadding(2)
    progressionKeysPanel:SizeToContents()

    self.propertySheet:AddSheet(
      "Progression Keys",
      progressionKeysPanel,
      "icon16/database_key.png",
      nil,
      nil,
      "Edit progression progressionKeys."
    )

    local progressionProgressionKeyForm = vgui.Create("expForm", progressionKeysPanel)
    progressionProgressionKeyForm:SetName("ProgressionKeys")
    progressionProgressionKeyForm:Dock(FILL)
    progressionProgressionKeyForm:SetIsHeadless(true)

    local infoLabel = vgui.Create("DLabel")
    infoLabel:SetText(
      "Progression Keys are used to track progression. Unlike goals, they are not visible to the player. For example a key could be 'unfavorable' and be set to true when the player has done something unfavorable in a quest/mission."
    )
    infoLabel:SetWrap(true)
    infoLabel:SetAutoStretchVertical(true)
    infoLabel:SizeToContents()
    infoLabel:Dock(TOP)
    progressionProgressionKeyForm:AddItem(infoLabel)

    self.progressionKeysListView = vgui.Create("expListView", self)
    self.progressionKeysListView:Dock(TOP)
    self.progressionKeysListView:SetTall(150)
    self.progressionKeysListView:SetMultiSelect(false)
    self.progressionKeysListView:AddColumn("Key")
    self.progressionKeysListView:AddColumn("Type")
    progressionProgressionKeyForm:AddItem(self.progressionKeysListView)

    local function openProgressionKeyEditDialog(editRow)
      local key = editRow and editRow:GetColumnText(1)
      local type = editRow and editRow:GetColumnText(2)
      local title = editRow and "Edit Progression Key" or "Add Progression Key"

      local dialog = vgui.Create("DFrame")
      dialog:SetAlwaysOnTop()
      dialog:SetTitle(title)
      dialog:SetSize(400, 400)
      dialog:Center()
      dialog:MakePopup()
      dialog:SetToRemoveOnceInvalid(self)

      local progressionKeyForm = vgui.Create("expForm", dialog)
      progressionKeyForm:SetCollapsible(false)
      progressionKeyForm:Dock(TOP)
      progressionKeyForm:SetName(title)

      local keyTextEntry = progressionKeyForm:TextEntry("Key")

      if (key) then
        keyTextEntry:SetValue(key)
      end

      local typeComboBox = progressionKeyForm:ComboBox("Type")
      typeComboBox:SetSortItems(false)
      typeComboBox:AddChoice("Boolean", "boolean", type == "boolean")
      typeComboBox:AddChoice("Number", "number", type == "number")

      local submitButton = vgui.Create("DButton", dialog)
      submitButton:SetText(editRow and "Save" or "Add")
      submitButton:Dock(BOTTOM)

      submitButton.DoClick = function(submitButton)
        local key = keyTextEntry:GetValue():Trim()
        local _, type = typeComboBox:GetSelected()

        if (key == "") then
          Schema.player.NotifyLocal("You must enter a key for the progressionKey!")
          return
        end

        if (editRow) then
          editRow:SetColumnText(1, key)
          editRow:SetColumnText(2, type)
        else
          self:AddProgressionKey(key, type)
        end

        self:UpdateProgressionKeysDropdowns()

        keyTextEntry:SetValue("")
        typeComboBox:SetValue("")
        dialog:Close()
      end
    end

    self.progressionKeysListView.DoDoubleClick = function(_, _, row)
      openProgressionKeyEditDialog(row)
    end

    self.addProgressionKeyButton = vgui.Create("DButton", self)
    self.addProgressionKeyButton:SetText("Add Progression Key")
    self.addProgressionKeyButton:Dock(BOTTOM)
    self.addProgressionKeyButton.DoClick = function()
      openProgressionKeyEditDialog()
    end
    progressionProgressionKeyForm:AddItem(self.addProgressionKeyButton)

    self.saveEditButton = vgui.Create("DButton")
    self.saveEditButton:Dock(BOTTOM)
    self.saveEditButton:SetText("Add")
    self.saveEditButton:SizeToContents()
    self:AddItem(self.saveEditButton)

    self.cancelEditButton = vgui.Create("DButton")
    self.cancelEditButton:Dock(BOTTOM)
    self.cancelEditButton:SetText("Cancel")
    self.cancelEditButton:SizeToContents()
    self.cancelEditButton:SetVisible(false)
    self:AddItem(self.cancelEditButton)

    self.cancelEditButton.DoClick = function(cancelEditButton)
      self:OnCancel()
    end

    self.saveEditButton.DoClick = function(saveEditButton)
      local uniqueID = self.uniqueIdTextEntry:GetValue():Trim()
      local scope = self.scopeTextEntry:GetValue():Trim()
      local name = self.nameTextEntry:GetValue():Trim()
      local _, completedKey = self.completedKeyDropdown:GetSelected()
      local _, isInProgressType = self.isInProgressDropdown:GetSelected()
      local isInProgressValue

      if (isInProgressType == "lua") then
        isInProgressValue = self.isInProgressValueTextEntry:GetValue():Trim()
      else
        _, isInProgressValue = self.isInProgressValueDropdown:GetSelected()
      end

      local progressionKeys = {}

      for _, line in pairs(self.progressionKeysListView:GetLines()) do
        table.insert(progressionKeys, {
          key = line:GetColumnText(1),
          type = line:GetColumnText(2),
        })
      end

      local goals = {}

      for _, line in pairs(self.progressionGoalsListView:GetLines()) do
        table.insert(goals, {
          key = line:GetColumnText(1),
          name = line:GetColumnText(2),
          type = line:GetColumnText(3),
          getProgressScript = line:GetColumnText(4),
        })
      end

      if (uniqueID == "") then
        Schema.player.NotifyLocal("You must enter a unique ID for the progression!")
        return
      end

      if (scope == "") then
        Schema.player.NotifyLocal("You must enter a scope for the progression!")
        return
      end

      if (name == "") then
        Schema.player.NotifyLocal("You must enter a name for the progression!")
        return
      end

      if (isInProgressType == "") then
        Schema.player.NotifyLocal(
          "You must select a key or lua for the 'in progress' key for the progression!")
        return
      end

      if (isInProgressType == "lua" and isInProgressValue == "") then
        Schema.player.NotifyLocal(
          "You must enter a lua expression to evaluate if the progression is in progress!")
        return
      end

      if (isInProgressType == "key" and not isInProgressValue) then
        Schema.player.NotifyLocal(
          "You must select a key to determine if the progression is in progress!")
        return
      end

      if (completedKey == "") then
        Schema.player.NotifyLocal("You must select a key to determine if the progression is completed!")
        return
      end

      local completedKeyProgressionKey = false

      for _, progressionKey in pairs(progressionKeys) do
        if (progressionKey.key == completedKey and progressionKey.type == "boolean") then
          completedKeyProgressionKey = true
          break
        end
      end

      if (not completedKeyProgressionKey) then
        Schema.player.NotifyLocal(
          "The completed key must be a boolean progressionKey that is defined in the progression!")
        return
      end

      local isInProgressInfo = { type = isInProgressType, value = isInProgressValue }

      self:OnSave(uniqueID, scope, name, completedKey, isInProgressInfo, progressionKeys, goals)
    end

    --[[
			Setup templates
		--]]

    local templates = {}
    table.insert(templates, {
      name = "Mission/Quest",
      fields = {
        completedKey = "completed",
        isInProgressInfo = {
          type = "key",
          value = "accepted",
        },
        progressionKeys = {
          { key = "completed", type = "boolean" },
          { key = "accepted",  type = "boolean" },
        },
      },
    })

    for k, template in ipairs(templates) do
      self.templateComboBox:AddChoice(template.name, k)
    end

    self.templateComboBox.OnSelect = function(_, _, value, k)
      local template = templates[k]

      if (template.fields.scope) then
        self.scopeTextEntry:SetText(template.fields.scope)
      end

      if (template.fields.name) then
        self.nameTextEntry:SetText(template.fields.name)
      end

      -- Insert progressionKeys into the progressionKeys listview
      clearListView(self.progressionKeysListView)
      clearListView(self.progressionGoalsListView)

      for _, progressionKey in pairs(template.fields.progressionKeys) do
        self:AddProgressionKey(progressionKey.key, progressionKey.type)
      end

      if (template.fields.goals) then
        for _, progressionGoal in pairs(template.fields.goals) do
          self:AddProgressionGoal(
            progressionGoal.key,
            progressionGoal.name,
            progressionGoal.type,
            progressionGoal.getProgressScript
          )
        end
      end

      self:UpdateProgressionKeysDropdowns()

      if (template.fields.completedKey) then
        self.completedKeyDropdown:ChooseOptionID(
          self.completedKeyDropdown:FindOptionByData(template.fields.completedKey)
        )
      end

      if (template.fields.isInProgressInfo) then
        self.isInProgressDropdown:ChooseOptionID(
          self.isInProgressDropdown:FindOptionByData(template.fields.isInProgressInfo.type)
        )

        if (template.fields.isInProgressInfo.type == "lua") then
          self.isInProgressValueTextEntry:SetText(template.fields.isInProgressInfo.value)
        else
          self.isInProgressValueDropdown:ChooseOptionID(
            self.isInProgressValueDropdown:FindOptionByData(template.fields.isInProgressInfo.value)
          )
        end
      end
    end

    progressionGeneralForm:InvalidateLayout(true)
  end

  --- Called when the form is saved (override this).
  ---	@param uniqueID string
  --- @param scope string
  ---	@param name string
  ---	@param completedKey string
  ---	@param isInProgressInfo ProgressionForEdit.IsInProgressInfo
  ---	@param progressionKeys ProgressionKey[]
  ---	@param goals ProgressionForEdit.Goal[]
  function PANEL:OnSave(uniqueID, scope, name, completedKey, isInProgressInfo, progressionKeys, goals)
    -- Override this
  end

  --- Called when the form is canceled.
  function PANEL:OnCancel()
    -- Override this
  end

  --- Adds a progressionKey to the progressionKeys listview.
  --- @param key string
  --- @param type string
  function PANEL:AddProgressionKey(key, type)
    self.progressionKeysListView:AddLine(key, type)
  end

  --- Updates the progressionKeys dropdowns based on the current progressionKeys listview.
  function PANEL:UpdateProgressionKeysDropdowns()
    local progressionKeys = {}

    for _, line in pairs(self.progressionKeysListView:GetLines()) do
      local type = line:GetColumnText(2)

      if (type ~= "boolean") then
        continue
      end

      table.insert(progressionKeys, {
        key = line:GetColumnText(1),
        type = type,
      })
    end

    local _, isInProgressValueDropdownIndex = self.isInProgressValueDropdown:GetSelected()
    local _, completedKeyDropdownIndex = self.completedKeyDropdown:GetSelected()

    self.isInProgressValueDropdown:Clear()
    self.completedKeyDropdown:Clear()

    for _, progressionKey in pairs(progressionKeys) do
      self.isInProgressValueDropdown:AddChoice(progressionKey.key, progressionKey.key,
        isInProgressValueDropdownIndex == progressionKey.key)
      self.completedKeyDropdown:AddChoice(progressionKey.key, progressionKey.key,
        completedKeyDropdownIndex == progressionKey.key)
    end
  end

  function PANEL:ClearProgression()
    self.uniqueIdTextEntry:SetValue("")
    self.scopeTextEntry:SetValue("")
    self.nameTextEntry:SetValue("")
    self.completedKeyDropdown:SetValue("")
    self.isInProgressDropdown:SetValue("")
    self.isInProgressValueDropdown:SetValue("")
    self.isInProgressValueTextEntry:SetValue("")

    clearListView(self.progressionKeysListView)
    clearListView(self.progressionGoalsListView)

    self:UpdateProgressionKeysDropdowns()
  end

  --- Adds a progression goal to the progressionGoals listview.
  --- @param key string
  --- @param name string
  --- @param type string
  --- @param getProgressScript string
  function PANEL:AddProgressionGoal(key, name, type, getProgressScript)
    self.progressionGoalsListView:AddLine(key, name, type, getProgressScript)
  end

  --- Loads a progression into the editor.
  --- @param progression ProgressionForEdit
  --- @param isEditting? boolean Whether the progression is being editting. (default true)
  function PANEL:LoadProgression(progression, isEditting)
    if (isEditting == nil) then
      isEditting = true
    end

    self.uniqueIdTextEntry:SetValue(progression.uniqueID)
    self.scopeTextEntry:SetValue(progression.scope)
    self.nameTextEntry:SetValue(progression.name)

    clearListView(self.progressionKeysListView)
    clearListView(self.progressionGoalsListView)

    for _, progressionKey in pairs(progression.progressionKeys) do
      self:AddProgressionKey(progressionKey.key, progressionKey.type)
    end

    for _, progressionGoal in pairs(progression.goals) do
      self:AddProgressionGoal(
        progressionGoal.key,
        progressionGoal.name,
        progressionGoal.type,
        progressionGoal.getProgressScript
      )
    end

    self:UpdateProgressionKeysDropdowns()

    self.isInProgressDropdown:ChooseOptionID(
      self.isInProgressDropdown:FindOptionByData(progression.isInProgressInfo.type)
    )

    local completedKeyIndex = self.completedKeyDropdown:FindOptionByData(progression.completedKey)

    if (completedKeyIndex) then
      self.completedKeyDropdown:ChooseOptionID(completedKeyIndex)
    end

    if (progression.isInProgressInfo.type == "lua") then
      self.isInProgressValueTextEntry:SetValue(progression.isInProgressInfo.value)
    else
      local isInProgressValueDropdownIndex = self.isInProgressValueDropdown
          :FindOptionByData(progression.isInProgressInfo.value)

      if (isInProgressValueDropdownIndex) then
        self.isInProgressValueDropdown:ChooseOptionID(
          isInProgressValueDropdownIndex
        )
      end
    end

    self.cancelEditButton:SetVisible(isEditting)
    self.saveEditButton:SetText(isEditting and "Save" or "Add")
    self.templateComboBox:GetParent():SetVisible(not isEditting)
  end

  vgui.Register("expProgressionEditorForm", PANEL, "expForm")
end

do
  --- @class expProgressionEditorSingle : DFrame
  local PANEL = {}

  --- Called when the panel is initialized.
  function PANEL:Init()
    self:SetTitle("Progression Editor")

    local panelList = vgui.Create("DPanelList", self)
    panelList:Dock(FILL)
    panelList:SetPadding(4)
    panelList:SetSpacing(4)
    panelList:EnableVerticalScrollbar()

    self.progressionEditForm = vgui.Create("expProgressionEditorForm", self)
    self.progressionEditForm:Dock(TOP)
    self.progressionEditForm:SetExpanded(true)
    self.progressionEditForm:SetIsHeadless(true)
    panelList:AddItem(self.progressionEditForm)

    self.progressionEditForm.OnSave = function(
        progressionEditForm,
        uniqueID,
        scope,
        name,
        completedKey,
        isInProgressInfo,
        progressionKeys,
        goals
    )
      Schema.PrintTableDev({
        uniqueID = uniqueID,
        scope = scope,
        name = name,
        completedKey = completedKey,
        isInProgressInfo = isInProgressInfo,
        progressionKeys = progressionKeys,
        goals = goals,
      })

      if (self:OnSave(uniqueID, scope, name, completedKey, isInProgressInfo, progressionKeys, goals)) then
        return
      end

      self:Close()
    end

    self.progressionEditForm.OnCancel = function()
      if (self:OnCancel()) then
        return
      end

      self:Close()
    end

    self:InvalidateLayout()
  end

  --- Called when the form is saved (override this).
  ---	@param uniqueID string
  --- @param scope string
  ---	@param name string
  ---	@param completedKey string
  ---	@param isInProgressInfo ProgressionForEdit.IsInProgressInfo
  ---	@param progressionKeys ProgressionKey[]
  ---	@param goals ProgressionForEdit.Goal[]
  function PANEL:OnSave(uniqueID, scope, name, completedKey, isInProgressInfo, progressionKeys, goals)
    -- Override this
  end

  --- Called when the form is canceled.
  function PANEL:OnCancel()
    -- Override this
  end

  --- Loads a progression into the editor.
  --- @param progression ProgressionForEdit
  function PANEL:LoadProgression(progression)
    self.progressionEditForm:LoadProgression(progression)
  end

  vgui.Register("expProgressionEditorSingle", PANEL, "DFrame")
end
