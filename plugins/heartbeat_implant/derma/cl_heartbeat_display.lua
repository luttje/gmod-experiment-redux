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
    self.currentScanLineY = 0

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
    local curTime = UnPredictedCurTime()
    local position = heartbeatPoint.position
    local aimVector = Angle(0, client:EyeAngles().y, 0):Forward()
    local direction = (position - client:GetPos()):GetNormalized()
    local distance = (position - client:GetPos()):Length()
    local dot = direction:Dot(aimVector)
    local cross = aimVector:Cross(direction)
    local crossZ = -cross.z

    local distanceRatio = math.Clamp(distance / PLUGIN.heartbeatScanRange, 0, 1)
    local edgeDistance = distanceRatio * (self:GetWide() / 2)

    local x = self:GetWide() / 2 + edgeDistance * crossZ
    local y = self:GetTall() / 2 - edgeDistance * dot

    if (not heartbeatPoint.discoveredAt) then
        if (y > self.currentScanLineY + self:GetScanLineHeight()) then
            return
        end

        heartbeatPoint.discoveredAt = curTime
    end

    local heartbeatLifetime = PLUGIN.heartbeatScanInterval
    local discoveredAt = heartbeatPoint.discoveredAt

    local alpha = 0
    local size = 32

    -- Draw a heartbeat since we've discovered it, beating twice during its lifetime
    if (curTime - discoveredAt < heartbeatLifetime) then

        local beatTime = heartbeatLifetime * .5

        -- Ensures the beat is at 1 at the start of the beat
		local fraction = math.abs((curTime - discoveredAt) % beatTime - beatTime * .5) / (beatTime * .5)
        alpha = 255 * fraction
        size = 32 + 8 * fraction

		surface.SetDrawColor(255, 0, 0, alpha)
	elseif (heartbeatPoint.staleAt) then
		-- Fade out the heartbeat point if it's outdated
		local staleAt = heartbeatPoint.staleAt
		local fadeTime = heartbeatLifetime * .5
		local fadeFraction = math.Clamp((curTime - staleAt) / fadeTime, 0, 1)

		alpha = math.Clamp(40 * (1 - fadeFraction), 0, 255)
        size = 14

		surface.SetDrawColor(255, 0, 0, alpha)
	end

    if (alpha <= 0) then
        return
    end

    surface.SetMaterial(PLUGIN.heartbeatPoint)
    surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)
end

function PANEL:GetScanLineHeight()
	return self:GetTall() * .1
end

function PANEL:DrawHeartbeatScan()
    local curTime = UnPredictedCurTime()
    local fraction = (curTime % PLUGIN.heartbeatScanInterval) / PLUGIN.heartbeatScanInterval
    local maxAlpha = 200
	local scanAlpha = maxAlpha * (1 - math.abs(fraction - 0.5) * 2)
    self.currentScanLineY = self:GetTall() * fraction

    surface.SetDrawColor(100, 0, 0, scanAlpha)
    surface.SetMaterial(PLUGIN.heartbeatGradient)
    surface.DrawTexturedRect(0, self.currentScanLineY, self:GetWide(), self:GetScanLineHeight())
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
    if (not client:GetCharacterNetVar("hasGhostheartPerk", false)) then
        surface.SetDrawColor(255, 255, 255, (alpha * .8) + (math.sin(curTime * 10) * (alpha * .3)))
        surface.SetMaterial(PLUGIN.heartbeatPoint)
        surface.DrawTexturedRect(width / 2 - 8, height / 2 - 8, 16, 16)
    end

    self:DrawHeartbeatScan()

    if (curTime >= self.nextHeartbeatCheck) then
        local newHeartbeatPoints = 0

        self.nextHeartbeatCheck = curTime + PLUGIN.heartbeatScanInterval

        -- Mark all old heartbeat points as outdated, removing those that are too old
        for k = #self.heartbeatPoints, 1, -1 do
            local heartbeatPoint = self.heartbeatPoints[k]

            if (not heartbeatPoint.staleAt) then
				heartbeatPoint.staleAt = curTime
            else
				table.remove(self.heartbeatPoints, k)
			end
		end

        local heartbeatScanRange = PLUGIN.heartbeatScanRange

        for _, entity in ipairs(ents.FindInSphere(position, heartbeatScanRange)) do
            if (not entity:IsPlayer() and not entity.IsBot) then
                continue
            end

            if (client == entity or entity:GetMoveType() == MOVETYPE_NOCLIP) then
                continue
            end

            if (entity:GetCharacterNetVar("hasGhostheartPerk", false)) then
                continue
            end

            local otherPlayerPosition = entity:GetPos()

			newHeartbeatPoints = newHeartbeatPoints + 1
            table.insert(self.heartbeatPoints, {
                position = otherPlayerPosition,
            })
        end

        if (self.lastHeartbeatAmount < newHeartbeatPoints) then
            LocalPlayer():EmitSound("items/flashlight1.wav", 30, 150)
		elseif (self.lastHeartbeatAmount > newHeartbeatPoints) then
            LocalPlayer():EmitSound("items/flashlight1.wav", 30, 70)
        end

        self.lastHeartbeatAmount = newHeartbeatPoints
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
