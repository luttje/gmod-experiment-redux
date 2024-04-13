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
