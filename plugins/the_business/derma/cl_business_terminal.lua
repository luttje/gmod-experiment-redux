local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
    PLUGIN.nextRenderIndex = PLUGIN.nextRenderIndex and PLUGIN.nextRenderIndex + 1 or 1
	local name = "businessTerminal" .. PLUGIN.nextRenderIndex
    self.renderTarget = GetRenderTarget(name, 512, 512)
	self.renderTargetMaterial = CreateMaterial(name, "UnlitGeneric", {
		["$basetexture"] = self.renderTarget:GetName(),
    })

    hook.Run("OnBusinessTerminalCreated", self)
end

function PANEL:DrawTextCentered(font, text, yOffset, textColor)
    local textWidth, textHeight = draw.SimpleTextOutlined(
		text,
		font,
		self:GetWide() / 2,
		yOffset,
		textColor,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1,
		Color(0, 0, 0, 255)
	)

    return yOffset + textHeight
end

function PANEL:DrawButton(text, font, yOffset)
    local textWidth, textHeight = Schema.GetCachedTextSize(font, text)
    local buttonWidth, buttonHeight = textWidth + 64, textHeight + 16
    local buttonX = self:GetWide() / 2 - buttonWidth / 2
    local buttonY = yOffset
    local isOver = self:GetTraceIsOver(buttonX, buttonY, buttonWidth, buttonHeight)

    local drawColor = isOver and Color(255, 0, 0, 255) or Color(0, 0, 0, 255)
    surface.SetDrawColor(drawColor)
    surface.DrawRect(buttonX, buttonY, buttonWidth, buttonHeight)

    local outlineColor = isOver and Color(255, 0, 0, 255) or Color(255, 255, 255, 255)
    surface.SetDrawColor(outlineColor)
    surface.DrawOutlinedRect(buttonX, buttonY, buttonWidth, buttonHeight)

    self:DrawTextCentered(font, text, buttonY + (buttonHeight / 2), Color(255, 255, 255, 255))
end

function PANEL:Think()
    if (self.currentItemModel and (not self.nextRender or self.nextRender < CurTime())) then
		self.nextRender = CurTime() + (1 / 30)
        -- local x, y = self:LocalToScreen(0, yOffset)

        self:LayoutEntity(self.currentItemModel)

        local min, max = self.currentItemModel:GetModelBounds()

        local size = (max - min)
        local center = (max + min) * 0.5

        -- Far enough away to see the model
        self.currentItemModel:SetPos(Vector(0, 0, 0))
        local cameraPosition = Vector(size.x * 1.5, size.y * 1.5, size.z * 1.5)

        -- Aiming at the center of the model
        local cameraAngles = ((self.currentItemModel:GetPos() + center) - cameraPosition):Angle()

        render.PushRenderTarget(self.renderTarget)
		render.Clear(255, 0, 0, 255, true, true)
        render.SuppressEngineLighting(true)
        render.ResetModelLighting(0.5, 0.5, 0.5)

        cam.Start3D(
            cameraPosition,
            cameraAngles,
            90,
            x,
            y,
            width,
            height,
            5,
            32768
        )
        self.currentItemModel:DrawModel()

        cam.End3D()
        render.SuppressEngineLighting(false)
		render.PopRenderTarget()
    end

    if (self.nextItem and self.nextItem > CurTime()) then
        return
    end

    self.nextItem = CurTime() + 1

    local possibleItems = {}

    for _, item in pairs(ix.item.list) do
        if (item.noBusiness or not item.price) then
            continue
        end

        possibleItems[#possibleItems + 1] = item
    end

	if (#possibleItems == 0) then
		return
	end

    self.currentItem = possibleItems[math.random(1, #possibleItems)]
    self.currentItemModel = IsValid(self.currentItemModel) and self.currentItemModel or ClientsideModel(self.currentItem.model, RENDERGROUP_OPAQUE)
	self.currentItemModel:SetModel(self.currentItem.model)
	self.currentItemModel:SetNoDraw(true)
	self.currentItemModel:SetIK(false)
end

function PANEL:DrawRandomOffering(yOffset, width, height)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(self.renderTargetMaterial)
	surface.DrawTexturedRect(0, yOffset, width, height)

	y = self:DrawTextCentered("ixSmallFont", self.currentItem.name, yOffset + (height * .75), Color(255, 255, 255, 125))
	self:DrawTextCentered("ixSmallFont", ix.currency.Get(self.currentItem.price), y, Color(255, 255, 255, 255))
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, width, height)

    local y = height * .1
    y = self:DrawTextCentered("ixBigFont", "The Business", y, Color(255, 0, 0, 255))
    y = self:DrawTextCentered("ixSmallFont", "For all your killing needs.", y, Color(255, 255, 255, 255))

    self:DrawRandomOffering(y, width, height - (height * 0.25) - y)

    self:DrawButton("Show Offerings", "ixBigFont", height * 0.8)
end

function PANEL:LayoutEntity(entity)
	if (not IsValid(entity)) then
		return
	end

	local sequence = entity:LookupSequence("idle")
	if (sequence > 0) then
		entity:ResetSequence(sequence)
	end

	entity:SetAngles(Angle(0, RealTime() * 100, 0))
end

function PANEL:GetTraceIsOver(x, y, width, height)
    if (not PLUGIN.worldMousePosition) then
        return false
    end

    local mouseX, mouseY = PLUGIN.worldMousePosition.x, PLUGIN.worldMousePosition.y

    return mouseX >= x and mouseX <= x + width and mouseY >= y and mouseY <= y + height
end

function PANEL:OnRemove()
	if (IsValid(self.currentItemModel)) then
		self.currentItemModel:Remove()
	end
end

vgui.Register("expBusinessTerminal", PANEL, "EditablePanel")
