local helixSkin = derma.GetNamedSkin("helix")

-- Make tooltips better readable by reducing the opacity of the background
helixSkin.Colours.DarkerBackground.a = 200

-- TODO: Find different place to show credits.
-- For now I just don't like the way credits are presented to players, it breaks immersion.
hook.Remove("PopulateHelpMenu", "ixCredits")

-- There's no need to bother players with technical details on the schema. It breaks immersion.
helixSkin.DrawHelixCurved = function() end
hook.Remove("CreateMenuButtons", "ixHelpMenu")

net.Receive("expClearEntityInfoTooltip", function()
	local targetEntity = net.ReadEntity()

	if (not IsValid(ix.gui.entityInfo)) then
		return
	end

	if (targetEntity ~= Entity(0) and targetEntity ~= ix.gui.entityInfo.entity) then
		return
	end

	ix.gui.entityInfo:Remove()
end)

function Schema:LoadFonts(headingFont, readableFont)
	local enabledAccessibilityFont = ix.option.Get("accessibilityFont", false)
	local accessibilityFontScale = ix.option.Get("accessibilityFontScale", 1)

	local function scaleFont(size)
		return size * accessibilityFontScale
	end

	if (enabledAccessibilityFont) then
		readableFont = "Arial"
	end

	surface.CreateFont("expTinyFont", {
		font = readableFont,
        size = scaleFont(math.max(ScreenScale(4), 16)),
		extended = true,
		weight = 600
	})

	surface.CreateFont("expSmallerFont", {
		font = readableFont,
        size = scaleFont(math.max(ScreenScale(6), 24)),
		extended = true,
		weight = 400
	})

	surface.CreateFont("expSmallItalicFont", {
		font = readableFont,
        size = scaleFont(math.max(ScreenScale(6), 26)),
		extended = true,
		weight = 400,
		italic = true
	})

	surface.CreateFont("expSmallOutlinedFont", {
		font = readableFont,
        size = scaleFont(math.max(ScreenScale(6), 24)),
		extended = true,
		shadow = true,
		weight = 600,
	})

	--[[
		Override default Helix fonts
	--]]
	timer.Simple(0, function()
		surface.CreateFont("ix3D2DFont", {
			font = headingFont,
			size = 128,
			extended = true,
			weight = 400
		})

		surface.CreateFont("ix3D2DMediumFont", {
			font = headingFont,
			size = 48,
			extended = true,
			weight = 400
		})

		surface.CreateFont("ix3D2DSmallFont", {
			font = headingFont,
			size = 24,
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixTitleFont", {
			font = headingFont,
			size = scaleFont(ScreenScale(30)),
			extended = true,
			weight = 600
		})

		surface.CreateFont("ixSubTitleFont", {
			font = headingFont,
			size = scaleFont(math.max(ScreenScale(16), 24)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixMenuMiniFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(4), 24)),
			weight = 300,
		})

		surface.CreateFont("ixMenuButtonFont", {
			font = readableFont,
			size = scaleFont(ScreenScale(14)),
			extended = true,
			weight = 100
		})

		surface.CreateFont("ixMenuButtonFontSmall", {
			font = readableFont,
			size = scaleFont(ScreenScale(10)),
			extended = true,
			weight = 100
		})

		surface.CreateFont("ixMenuButtonFontThick", {
			font = readableFont,
			size = scaleFont(ScreenScale(14)),
			extended = true,
			weight = 600
		})

		surface.CreateFont("ixMenuButtonLabelFont", {
			font = readableFont,
			size = 28,
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixMenuButtonHugeFont", {
			font = headingFont,
			size = scaleFont(ScreenScale(24)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixToolTipText", { -- Never used
			font = readableFont,
			size = scaleFont(20),
			extended = true,
			weight = 600
		})

		surface.CreateFont("ixMonoSmallFont", {
			font = "Consolas",
			size = scaleFont(12),
			extended = true,
			weight = 800
		})

		surface.CreateFont("ixMonoMediumFont", {
			font = "Consolas",
			size = scaleFont(22),
			extended = true,
			weight = 800
		})

		surface.CreateFont("ixBigFont", {
			font = headingFont,
			size = scaleFont(36),
			extended = true,
			weight = 4000
		})

		surface.CreateFont("ixMediumFont", {
			font = readableFont,
			size = scaleFont(28),
			extended = true,
			weight = 4000
		})

		surface.CreateFont("ixNoticeFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(8), 24)),
			weight = 400,
			extended = true,
			antialias = true
		})

		surface.CreateFont("ixMediumLightFont", {
			font = headingFont,
			size = scaleFont(math.max(ScreenScale(8), 22)),
			extended = true,
			weight = 600
		})

		surface.CreateFont("ixMediumLightBlurFont", {
			font = headingFont,
			size = scaleFont(math.max(ScreenScale(8), 22)),
			extended = true,
			weight = 600,
			blursize = 4
		})

		surface.CreateFont("ixGenericFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(7), 24)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixChatFont", {
			font = readableFont,
			size = math.max(ScreenScale(7), 24) * ix.option.Get("chatFontScale", 1),
			extended = true,
			weight = 600,
			antialias = true
		})

		surface.CreateFont("ixChatFontItalics", {
			font = readableFont,
			size = math.max(ScreenScale(7), 24) * ix.option.Get("chatFontScale", 1),
			extended = true,
			weight = 600,
			antialias = true,
			italic = true
		})

		surface.CreateFont("ixSmallTitleFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(12), 26)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixMinimalTitleFont", {
			font = headingFont,
			size = scaleFont(math.max(ScreenScale(8), 26)),
			extended = true,
			weight = 800
		})

		surface.CreateFont("ixSmallFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(6), 24)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixItemDescFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(6), 24)),
			extended = true,
			shadow = true,
			weight = 400
		})

		surface.CreateFont("ixSmallBoldFont", {
			font = readableFont,
			size = scaleFont(math.max(ScreenScale(8), 22)),
			extended = true,
			weight = 800
		})

		surface.CreateFont("ixItemBoldFont", {
			font = readableFont,
			shadow = true,
			size = scaleFont(math.max(ScreenScale(8), 20)),
			extended = true,
			weight = 800
		})

		surface.CreateFont("ixIntroTitleFont", {
			font = headingFont,
			size = scaleFont(math.min(ScreenScale(128), 128)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixIntroTitleBlurFont", {
			font = headingFont,
			size = scaleFont(math.min(ScreenScale(128), 128)),
			extended = true,
			weight = 400,
			blursize = 4
		})

		surface.CreateFont("ixIntroSubtitleFont", {
			font = headingFont,
			size = scaleFont(ScreenScale(28)),
			extended = true,
			weight = 400
		})

		surface.CreateFont("ixIntroSmallFont", {
			font = headingFont,
			size = scaleFont(ScreenScale(24)),
			extended = true,
			weight = 400
		})
	end)
end

-- We override the default main menu so we can customize it
function Schema:ScoreboardShow()
	if (LocalPlayer():GetCharacter()) then
		vgui.Create("expMenu")

		-- We MUST return true to prevent default Helix behavior
		return true
	end
end

-- Copied from gamemode/core/derma/cl_help.lua to only show a tab with commands
function Schema:CreateMenuButtons(tabs)
	tabs["help"] = function(parentContainer)
		local backgroundColor = Color(0, 0, 0, 66)
		local container = parentContainer:Add("DScrollPanel")
		container:Dock(FILL)
		container:DockMargin(8, 0, 0, 0)
		container.Paint = function(_, width, height)
			surface.SetDrawColor(backgroundColor)
			surface.DrawRect(0, 0, width, height)
		end
		container.DisableScrolling = function()
			container:GetCanvas():SetVisible(false)
			container:GetVBar():SetVisible(false)
			container.OnChildAdded = function() end
		end

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
			title:SetFont("ixSmallBoldFont")
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
	buffManager.characterPanel = panel
	panel.buffs.manager = buffManager

    panel.buffs:SizeToContents()

	hook.Run("CreateCharacterBuffInfo", panel, panel.buffs)
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

function Schema:CreateItemInteractionMenu(inventoryPanel, menu, itemTable)
	local hasCashbackPerk, cashbackPerkTable = Schema.perk.GetOwned("cashback")

	if (not hasCashbackPerk) then
		return
	end

	if (not itemTable.price or itemTable.noBusiness) then
		return
	end

	-- TODO: This is a hacky way to get cashback to appear at the end of the menu, if Helix provides a way to do this, we should use it
	local oldMenuOpen = menu.Open

	function menu:Open(...)
		menu:AddOption(L("cashback"), function()
			Derma_Query(L("cashbackConfirmation", cashbackPerkTable.returnFraction * 100), L("cashback"), L("yes"),
				function()
					net.Start("expCashbackRequest")
					net.WriteUInt(itemTable:GetID(), 32)
					net.SendToServer()
				end, L("no"))
		end):SetImage("icon16/money_delete.png")

		oldMenuOpen(self, ...)
	end
end

function Schema:PlayerPerkBought(client, perk)
	if (IsValid(Schema.businessPanel)) then
		Schema.businessPanel:Refresh()
	end
end

function Schema:NetworkEntityCreated(entity)
	local client = LocalPlayer()

	if (entity:GetClass() ~= "prop_ragdoll" or not IsValid(client)) then
		return
	end

	local player = entity:GetNetVar("player", NULL)

	if (not IsValid(player)) then
		return
	end

	entity.GetEntityMenu = function(entity)
		local target = entity:GetNetVar("player", NULL)
		local options = {}

		hook.Run("AdjustPlayerRagdollEntityMenu", options, target, entity)

		return options
	end
end

function Schema:AdjustPlayerRagdollEntityMenu(options, target, corpse)
	if (target:Alive()) then
		if (target:IsRestricted()) then
			options[L("searchTied")] = true
			options[L("untie")] = true
		end

		return
	end

	options[L("searchCorpse")] = true

	local hasMutilatorPerk, mutilatorPerkTable = Schema.perk.GetOwned("mutilator")

	if (hasMutilatorPerk and corpse:GetNetVar("mutilated", 0) < mutilatorPerkTable.maximumMutilations) then
		options[L("mutilateCorpse")] = true
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
		local position, angles = LocalToWorld(itemTable.attachmentOffsetVector, itemTable.attachmentOffsetAngles,
			matrix:GetTranslation(), matrix:GetAngles())

		model:SetPos(position)
		model:SetAngles(angles)
		model:SetupBones()
		model:DrawModel()
	end

	Schema.clientsideModelCache = clientsideModelCache
end
