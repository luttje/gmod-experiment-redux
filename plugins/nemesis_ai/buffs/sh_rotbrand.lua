local BUFF = BUFF

BUFF.name = "Rotbrand"
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 27,
	y = 11,
	size = 32,
}
BUFF.durationInSeconds = 30 * 60
BUFF.persistThroughDeath = true
BUFF.stackOnDuplicate = true
BUFF.description =
"You're next in line for the Locker Rot Virus. Unprovoked aggression during the Locker Rot Virus causes this to happen."

if (not SERVER) then
	return
end

-- TODO: Track defensive actions and punish unprovoked aggression with this buff.
