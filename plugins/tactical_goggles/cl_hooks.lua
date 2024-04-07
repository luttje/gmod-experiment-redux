local PLUGIN = PLUGIN

function PLUGIN:RenderScreenspaceEffects()
    if (not IsValid(LocalPlayer())) then
        return
    end

	if (not LocalPlayer():HasTacticalGogglesActivated()) then
		return
	end

	render.UpdateScreenEffectTexture()

	self.tacticalOverlay:SetFloat("$refractamount", 0.3)
	self.tacticalOverlay:SetFloat("$envmaptint", 0)
	self.tacticalOverlay:SetFloat("$envmap", 0)
	self.tacticalOverlay:SetFloat("$alpha", 0.6)
	self.tacticalOverlay:SetInt("$ignorez", 1)

	render.SuppressEngineLighting(true)
		render.SetMaterial(self.tacticalOverlay)
		render.DrawScreenQuad()
	render.SuppressEngineLighting(false)
end

function PLUGIN:Tick()
    local client = LocalPlayer()

    if (not IsValid(client)) then
        return
    end

	local character = client:GetCharacter()

	if (not character) then
		return
	end

	if (not client:HasTacticalGogglesActivated()) then
		if (IsValid(ix.gui.tacticalDisplay)) then
			ix.gui.tacticalDisplay:Remove()
		end

		return
	elseif (not IsValid(ix.gui.tacticalDisplay)) then
		ix.gui.tacticalDisplay = vgui.Create("expTacticalDisplay")
	end

	local curTime = CurTime()
	local health = client:Health()
    local armor = client:Armor()

    if (self.nextTacticalWarning and curTime < self.nextTacticalWarning) then
		return
	end

	if (self.lastHealth) then
		if (health < self.lastHealth) then
			if (health == 0) then
				self:AddDisplayLine("ERROR! Shutting down...", Color(255, 0, 0, 255))
			else
				self:AddDisplayLine("WARNING! Physical bodily trauma detected...", Color(255, 0, 0, 255))
			end

			self.nextTacticalWarning = curTime + 2
		elseif (health > self.lastHealth) then
			if (health == 100) then
				self:AddDisplayLine("Physical body systems restored...", Color(0, 255, 0, 255))
			else
				self:AddDisplayLine("Physical body systems regenerating...", Color(0, 0, 255, 255))
			end

			self.nextTacticalWarning = curTime + 2
		end
	end

    if (self.lastArmor) then
        if (armor < self.lastArmor) then
            if (armor == 0) then
                self:AddDisplayLine("WARNING! External protection exhausted...", Color(255, 0, 0, 255))
            else
                self:AddDisplayLine("WARNING! External protection damaged...", Color(255, 0, 0, 255))
            end

            self.nextTacticalWarning = curTime + 2
        elseif (armor > self.lastArmor) then
            if (armor == 100) then
                self:AddDisplayLine("External protection systems restored...", Color(0, 255, 0, 255))
            else
                self:AddDisplayLine("External protection systems regenerating...", Color(0, 0, 255, 255))
            end

            self.nextTacticalWarning = curTime + 2
        end
    end

	if (not self.nextRandomLine or curTime >= self.nextRandomLine) then
		local text = self.randomDisplayLines[ math.random(1, #self.randomDisplayLines) ]

		if (text and self.lastRandomDisplayLine ~= text) then
            self:AddDisplayLine(text)

			self.lastRandomDisplayLine = text
		end

		self.nextRandomLine = curTime + 3
	end

	self.lastHealth = health
	self.lastArmor = armor
end
