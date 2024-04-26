local PLUGIN = PLUGIN
local BUFF = BUFF

BUFF.name = "Siege Surge"
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 4,
	y = 20,
	size = 32,
}
BUFF.durationInSeconds = 5 * 60
BUFF.maxStacks = 5
BUFF.description = "After destroying a structure belonging to '%s' with a crowbar, the next structure of '%s' or members of their alliance will be twice as weak to you."

--- @param client Player
--- @param buff ActiveBuff
--- @return string
function BUFF:GetDescription(client, buff)
	local victimName = "someone"

	if (buff.data.victimName) then
		victimName = buff.data.victimName
	end

	return string.format(self.description, victimName, victimName)
end
