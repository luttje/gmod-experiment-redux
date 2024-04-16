local BUFF = BUFF

BUFF.name = "Siege Surge"
BUFF.stackedName = "Siege Surge (x%d)"
BUFF.backgroundImage = "experiment-redux/symbol_background"
BUFF.backgroundColor = Color(48,93,124,255)
BUFF.foregroundImage = "experiment-redux/symbol/troop"
BUFF.durationInSeconds = 5 * 60
BUFF.maxStacks = 5
BUFF.description = "After destroying a structure belonging to '%s' with a crowbar, the next structure of '%s' or members of their alliance will be twice as weak to you."

---@param client Player
---@param buff ActiveBuff
---@return string
function BUFF:GetDescription(client, buff)
	local victim = buff.data.victim
	local victimName = "someone"

	if (IsValid(victim)) then
		victimName = victim:Name()
	end

	return string.format(self.description, victimName, victimName)
end

---@param client Player
---@param buff ActiveBuff
---@return boolean?
function BUFF:OnPlayerSecondElapsed(client, buff)
	if (not IsValid(buff.data.victim)) then
		-- The victim has left the server, so remove the buff
		return false
	end
end
