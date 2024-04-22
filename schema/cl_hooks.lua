local helixSkin = derma.GetNamedSkin("helix")

-- Make tooltips better readable by reducing the opacity of the background
helixSkin.Colours.DarkerBackground.a = 200

-- TODO: Find different place to show credits.
-- For now I just don't like the way credits are presented to players, it breaks immersion.
hook.Remove("PopulateHelpMenu", "ixCredits")

-- There's no need to bother players with technical details on the schema. It breaks immersion.
helixSkin.DrawHelixCurved = function() end
hook.Remove("CreateMenuButtons", "ixHelpMenu")

function Schema:LoadFonts(font, genericFont)
    surface.CreateFont("expTinyFont", {
        font = font,
        size = math.max(ScreenScale(4), 12),
        extended = true,
        weight = 400
    })

    surface.CreateFont("expSmallerFont", {
        font = font,
        size = math.max(ScreenScale(6), 12),
        extended = true,
        weight = 400
    })

    surface.CreateFont("expSmallItalicFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 400,
        italic = true
    })

    surface.CreateFont("expSmallOutlinedFont", {
        font = font,
        size = math.max(ScreenScale(6), 12),
        extended = true,
        shadow = true,
        weight = 600,
    })
end

-- Copied from gamemode/core/derma/cl_help.lua to only show a tab with commands
function Schema:CreateMenuButtons(tabs)
    tabs["help"] = function(container)
        local info = container:Add("DLabel")
        info:SetFont("ixSmallFont")
        info:SetText(L("helpCommands"))
        info:SetContentAlignment(5)
        info:SetTextColor(color_white)
        info:SetExpensiveShadow(1, color_black)
        info:Dock(TOP)
        info:DockMargin(0, 0, 0, 8)
        info:SizeToContents()
        info:SetTall(info:GetTall() + 16)

        info.Paint = function(_, width, height)
            surface.SetDrawColor(ColorAlpha(derma.GetColor("Info", info), 160))
            surface.DrawRect(0, 0, width, height)
        end

        for uniqueID, command in SortedPairs(ix.command.list) do
            if (command.OnCheckAccess and not command:OnCheckAccess(LocalPlayer())) then
                continue
            end

            local bIsAlias = false
            local aliasText = ""

            -- we want to show aliases in the same entry for better readability
            if (command.alias) then
                local alias = istable(command.alias) and command.alias or { command.alias }

                for _, v in ipairs(alias) do
                    if (v:lower() == uniqueID) then
                        bIsAlias = true
                        break
                    end

                    aliasText = aliasText .. ", /" .. v
                end

                if (bIsAlias) then
                    continue
                end
            end

            local title = container:Add("DLabel")
            title:SetFont("ixMediumLightFont")
            title:SetText("/" .. command.name .. aliasText)
            title:Dock(TOP)
            title:SetTextColor(ix.config.Get("color"))
            title:SetExpensiveShadow(1, color_black)
            title:SizeToContents()

            local syntaxText = command.syntax
            local syntax

            if (syntaxText ~= "" and syntaxText ~= "[none]") then
                syntax = container:Add("DLabel")
                syntax:SetFont("ixMediumLightFont")
                syntax:SetText(syntaxText)
                syntax:Dock(TOP)
                syntax:SetTextColor(color_white)
                syntax:SetExpensiveShadow(1, color_black)
                syntax:SetWrap(true)
                syntax:SetAutoStretchVertical(true)
                syntax:SizeToContents()
            end

            local descriptionText = command:GetDescription()

            if (descriptionText ~= "") then
                local description = container:Add("DLabel")
                description:SetFont("ixSmallFont")
                description:SetText(descriptionText)
                description:Dock(TOP)
                description:SetTextColor(color_white)
                description:SetExpensiveShadow(1, color_black)
                description:SetWrap(true)
                description:SetAutoStretchVertical(true)
                description:SizeToContents()
                description:DockMargin(0, 0, 0, 8)
            elseif (syntax) then
                syntax:DockMargin(0, 0, 0, 8)
            else
                title:DockMargin(0, 0, 0, 8)
            end
        end
    end
end

function Schema:InitPostEntity()
	Schema.buff.CreateHUDPanel()
end

function Schema:CharacterLoaded(character)
    Schema.buff.CreateHUDPanel()
end

function Schema:ScreenResolutionChanged(oldWidth, oldHeight)
	Schema.buff.CreateHUDPanel()
end

function Schema:CreateCharacterInfo(panel)
	-- Adds the buff manager to the character panel
	panel.buffs = panel:Add("ixCategoryPanel")
	panel.buffs:SetText(L("buffs"))
	panel.buffs:Dock(TOP)
	panel.buffs:DockMargin(0, 0, 0, 8)

	local buffManager = panel.buffs:Add("expBuffManager")
	buffManager:Dock(TOP)
	buffManager:RefreshBuffs()
	panel.buffs.manager = buffManager

	panel.buffs:SizeToContents()
end

function Schema:UpdateCharacterInfo(panel, character)
	if (panel.buffs and panel.buffs.manager) then
		panel.buffs.manager:RefreshBuffs()
	end
end

function Schema:ContextMenuOpen()
	return LocalPlayer():IsAdmin() and IS_CONTEXT_MENU_ENABLED
end

function Schema:RenderScreenspaceEffects()
	if (not IsValid(LocalPlayer())) then
		return
	end

	local modify = {}
	local curTime = CurTime()

	if (self.flashEffect) then
		local timeLeft = math.Clamp(self.flashEffect.endAt - curTime, 0, self.flashEffect.duration)
		local incrementer = 1 / self.flashEffect.duration

		if (timeLeft > 0) then
			modify = {}

			modify["$pp_colour_brightness"] = 0
			modify["$pp_colour_contrast"] = 1 + (timeLeft * incrementer)
			modify["$pp_colour_colour"] = 1 - (incrementer * timeLeft)
			modify["$pp_colour_addr"] = incrementer * timeLeft
			modify["$pp_colour_addg"] = 0
			modify["$pp_colour_addb"] = 0
			modify["$pp_colour_mulr"] = 1
			modify["$pp_colour_mulg"] = 0
			modify["$pp_colour_mulb"] = 0

			DrawColorModify(modify)
			DrawMotionBlur(1 - (incrementer * timeLeft), 1, 0)
		else
			self.flashEffect = nil
		end
	end

	if (self.tearGassed) then
		local timeLeft = self.tearGassed - curTime

		if (timeLeft > 0) then
			if (timeLeft >= 15) then
				DrawMotionBlur(0.1 + (0.9 / (20 - timeLeft)), 1, 0)
			else
				DrawMotionBlur(0.1, 1, 0)
			end
		else
			self.tearGassed = nil
		end
	end
end

function Schema:PostDrawHUD()
	local curTime = CurTime()

	if (self.stunEffects) then
		for k, stunEffect in pairs(self.stunEffects) do
			local alpha = math.Clamp((255 / stunEffect.duration) * (stunEffect.endAt - curTime), 0, 255)

			if (alpha ~= 0) then
				draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha))
			else
				table.remove(self.stunEffects, k)
			end
		end
	end
end

function Schema:PopulateCharacterInfo(client, character, tooltip)
	if (client:IsRestricted()) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("tiedUp"))
		panel:SizeToContents()
	elseif (client:GetNetVar("tying")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("beingTied"))
		panel:SizeToContents()
	elseif (client:GetNetVar("untying")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("beingUntied"))
		panel:SizeToContents()
	end
end

-- TODO: We could use weaponItemTable.pacData to let PAC3 handle the attachment
function Schema:PostPlayerDraw(client)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	local clientsideModelCache = Schema.clientsideModelCache or {}
	local weapons = client:GetWeapons()

	for _, weapon in pairs(weapons) do
		local class = weapon:GetClass()
		local itemTable = Schema.GetWeaponAttachment(class)

		if (not itemTable) then
			continue
		end

		if (IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == class) then
			continue
		end

		local model = clientsideModelCache[class]

		if (not IsValid(model)) then
			model = ClientsideModel(itemTable.model)
			model:SetNoDraw(true)

			clientsideModelCache[class] = model
		end

		local boneID = client:LookupBone(itemTable.attachmentBone)

		if (not boneID) then
			continue
		end

		local matrix = client:GetBoneMatrix(boneID)
		local position, angles = LocalToWorld(itemTable.attachmentOffsetVector, itemTable.attachmentOffsetAngles, matrix:GetTranslation(), matrix:GetAngles())

		model:SetPos(position)
		model:SetAngles(angles)
		model:SetupBones()
		model:DrawModel()
	end

	Schema.clientsideModelCache = clientsideModelCache
end
