local PLUGIN = PLUGIN
local BUFF = BUFF

BUFF.name = "Deserter's Demise"
BUFF.backgroundImage = "experiment-redux/symbol_background"
BUFF.backgroundColor = Color(124, 48, 55, 255)
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 4,
	y = 20,
	size = 32,
}
BUFF.durationInSeconds = 5 * 60
BUFF.resetOnDuplicate = true
BUFF.description =
"You've recently taken or dealt damage. Disconnecting with this debuff active will cause you to drop all your belongings."

if (not SERVER) then
	return
end

function BUFF.hooks:EntityTakeDamage(victim, damageInfo)
	if (victim:IsPlayer()) then
		Schema.buff.SetActive(victim, "deserters_demise")
	end

	local attacker = damageInfo:GetAttacker()

	if (IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim) then
		Schema.buff.SetActive(attacker, "deserters_demise")
	end
end

function BUFF.hooks:PlayerDisconnected(client)
	if (client:SteamID() == nil or client:SteamID64() == nil) then
		--[[
		From the wiki:
		"
			NEED TO VALIDATE
			Player:SteamID, Player:SteamID64, and the like can return nil here.
		"
		https://wiki.facepunch.com/gmod/GM:PlayerDisconnected

		Let's return the favor and validate whether nil is ever returned.
		--]]
		local playerData = {
			time = os.time(),
			version = VERSION,
			versionStr = VERSIONSTR,
			jitVersion = jit.version,
			jitVersionNum = jit.version_num,
			steamID = tostring(client:SteamID()),
			steamID64 = tostring(client:SteamID64()),
			steamName = tostring(client:SteamName()),
		}
		ErrorNoHaltWithStack("Player disconnected (wiki bug/issue validation): " .. util.TableToJSON(playerData) .. "\n")
		file.Write("disconnect_validation.txt", util.TableToJSON(playerData) .. "\n")
	end

	if (not Schema.buff.GetActive(client, self.index)) then
		return
	end

	local character = client:GetCharacter()

	if (not character) then
		return
	end

	Schema.PlayerDropAllItems(client, true)
end
