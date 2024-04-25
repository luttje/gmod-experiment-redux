ATTRIBUTE.name = "Agility"
ATTRIBUTE.description = "Affects your overall nimbleness, like how fast you duck or climb ladders."

function ATTRIBUTE:OnSetup(client, value, character)
	local maximum = self.maxValue or ix.config.Get("maxAttributes", 100)
	local fraction = math.Clamp(value / maximum, 0, 1)

    local duckMin, duckMax = 0.2, 0.6
    local duckRange = duckMax - duckMin
	local duckSpeed = math.Clamp(duckMax - (duckRange * fraction), duckMin, duckMax)
    client:SetDuckSpeed(duckSpeed)
    client:SetUnDuckSpeed(duckSpeed)

    local ladderClimbMin, ladderClimbMax = 80, 350
    local ladderClimbRange = ladderClimbMax - ladderClimbMin
	client:SetLadderClimbSpeed(math.Clamp(ladderClimbMin + (ladderClimbRange * fraction), ladderClimbMin, ladderClimbMax))
end
