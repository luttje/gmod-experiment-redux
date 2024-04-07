local PLUGIN = PLUGIN

local PANEL = {}

local ASPECT_RATIO = 3 / 2

function PANEL:Init()
    if (IsValid(ix.gui.heartbeatDisplay)) then
        ix.gui.heartbeatDisplay:Remove()
    end

    self:ParentToHUD()

	self.lastHeartbeatAmount = 0
	self.nextHeartbeatCheck = 0
	self.heartbeatPoints = {}

    ix.gui.heartbeatDisplay = self
end

function PANEL:PerformLayout(width, height)
	local newWidth = math.min(ScrW() * .3, 400)
    local newHeight = newWidth / ASPECT_RATIO

    self.padding = newHeight * 0.05

	if (newWidth == width and newHeight == height) then
		return
	end

    self:SetSize(newWidth, newHeight)
	self:SetPos(ScrW() - newWidth - self.padding, ScrH() - newHeight - self.padding)
end

function PANEL:DrawHeartbeatPoint(heartbeatPoint)
    local client = LocalPlayer()
    local position = heartbeatPoint.position
    local aimVector = Angle(0, client:EyeAngles().y, 0):Forward()
    local direction = (position - client:GetPos()):GetNormalized()
	local distance = (position - client:GetPos()):Length()
    local dot = direction:Dot(aimVector)
    local cross = aimVector:Cross(direction)
    local crossZ = -cross.z

    local angleInRadians = math.acos(dot)

	local heartbeatLifetime = PLUGIN.heartbeatScanInterval
    local discoveredAt = heartbeatPoint.discoveredAt
    local curTime = UnPredictedCurTime()

    local alpha = 255 * .4
    local size = 16

	alpha = alpha * math.Clamp(1 - math.abs((curTime - discoveredAt) / heartbeatLifetime - 0.5) * 2, 0, 1)

    if (alpha <= 0) then
        return
    end

    local distanceRatio = math.Clamp(distance / PLUGIN.heartbeatScanRange, 0, 1)
    local edgeDistance = (0.5 + (0.5 * distanceRatio)) * (self:GetWide() / 2)

    local x = self:GetWide() / 2 + (crossZ > 0 and 1 or -1) * edgeDistance * math.sin(angleInRadians)
    local y = self:GetTall() / 2 - edgeDistance * dot

    surface.SetDrawColor(255, 0, 0, alpha)
    surface.SetMaterial(PLUGIN.heartbeatPoint)
    surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)
end

function PANEL:DrawHeartbeatScan(heartbeatScanUntil)
    local curTime = UnPredictedCurTime()
	local fraction = math.max(heartbeatScanUntil - curTime, 0)
	local scanAlpha = math.min(255 * fraction, 255 * .5)
	local y = self:GetTall() * (1 - fraction)

    if (scanAlpha > 0) then
        surface.SetDrawColor(100, 0, 0, scanAlpha * 0.5)
        surface.SetMaterial(PLUGIN.heartbeatGradient)
        surface.DrawTexturedRect(0, y, self:GetWide(), self:GetTall() * .1)

        return true
    end

	return false
end

function PANEL:Paint(width, height)
	local client = LocalPlayer()
	local position = client:GetPos()
    local curTime = UnPredictedCurTime()

    local alpha = 255 * .5

	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(PLUGIN.heartbeatOverlay)
    surface.DrawTexturedRect(0, 0, width, height)

    -- Draw ourselves manually
	if (not client:GetCharacterNWBool("hasGhostheartPerk", false)) then
		surface.SetDrawColor(255, 255, 255, (alpha * .8) + (math.sin(curTime * 10) * (alpha * .3)))
		surface.SetMaterial(PLUGIN.heartbeatPoint)
		surface.DrawTexturedRect(width / 2 - 8, height / 2 - 8, 16, 16)
	end

	if (self.heartbeatScanUntil) then
		if (not self:DrawHeartbeatScan(self.heartbeatScanUntil)) then
			self.heartbeatScanUntil = nil
		end
	end

	if (curTime >= self.nextHeartbeatCheck) then
		self.nextHeartbeatCheck = curTime + PLUGIN.heartbeatScanInterval
        self.heartbeatScanUntil = curTime + PLUGIN.heartbeatScanInterval
		self.heartbeatPoints = {}

		local heartbeatScanRange = PLUGIN.heartbeatScanRange

		for _, entity in ipairs(ents.FindInSphere(position, heartbeatScanRange)) do
            if (not entity:IsPlayer() and not entity.IsBot) then
				continue
			end

            if (client == entity or entity:GetMoveType() == MOVETYPE_NOCLIP) then
				continue
			end

            if (entity:GetCharacterNWBool("hasGhostheartPerk", false)) then
				continue
			end

            local otherPlayerPosition = entity:GetPos()

			table.insert(self.heartbeatPoints, {
                position = otherPlayerPosition,
                discoveredAt = curTime,
            })
		end

		if (self.lastHeartbeatAmount > #self.heartbeatPoints) then
			LocalPlayer():EmitSound("items/flashlight1.wav", 25)
		end

		self.lastHeartbeatAmount = #self.heartbeatPoints
	end

    for _, heartbeatPoint in ipairs(self.heartbeatPoints) do
        self:DrawHeartbeatPoint(heartbeatPoint)
    end

    -- Draw a nice border
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawOutlinedRect(0, 0, width, height, 4)

end

vgui.Register("expHeartbeatDisplay", PANEL, "Panel")

if (IsValid(ix.gui.heartbeatDisplay)) then
	vgui.Create("expHeartbeatDisplay")
end
