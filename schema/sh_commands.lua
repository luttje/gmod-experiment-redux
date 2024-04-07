do
	local COMMAND = {}

	COMMAND.description = "Search the tied character you are looking at."

	function COMMAND:OnRun(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:IsRestricted()) then
			if (!client:IsRestricted()) then
				Schema.SearchPlayer(client, target)
			else
				return "@notNow"
			end
		end
	end

	ix.command.Add("CharSearch", COMMAND)
end

do
	if (SERVER) then
		util.AddNetworkString("AllianceCreateNameInput")
	end

	local COMMAND = {}

	COMMAND.description = "Create a new alliance."

	function COMMAND:OnRun(client)
		net.Start("AllianceCreateNameInput")
		net.Send(client)
	end

	ix.command.Add("AllyCreate", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Invite the character you are looking at to your alliance."

	function COMMAND:OnRun(client)
		local target = Schema.GetPlayer(client:GetEyeTraceNoCursor().Entity)

		if (not target) then
			ix.util.Notify("You must look at a character!", client)
			return
		end

		Schema.alliance.RequestInviteMember(client, target)
	end

	ix.command.Add("AllyInvite", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Kick a character out of your alliance."
	COMMAND.arguments = {ix.type.character}

	function COMMAND:OnRun(client, target)
		Schema.alliance.RequestKick(client, target)
	end

	ix.command.Add("AllyKick", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Leave your alliance."

	function COMMAND:OnRun(client)
		Schema.alliance.RequestLeave(client)
	end

	ix.command.Add("AllyLeave", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Fake damage to a certain body part of yourself or the character you are looking at."
	COMMAND.arguments = {
		bit.bor(ix.type.string, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, bodyPart, amount)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (not IsValid(target) or not target:IsPlayer()) then
			target = client
		end

		amount = amount or 2

		if (not target:Alive()) then
			ix.util.Notify("This character is dead!", client)
			return
		end

		bodyPart = (bodyPart or "head"):lower()
		local hitGroup = HITGROUP_HEAD

		if (bodyPart == "head") then
			hitGroup = HITGROUP_HEAD
		elseif (bodyPart == "chest") then
			hitGroup = HITGROUP_CHEST
		elseif (bodyPart == "stomach") then
			hitGroup = HITGROUP_STOMACH
		elseif (bodyPart == "leftarm" or bodyPart == "left arm") then
			hitGroup = HITGROUP_LEFTARM
		elseif (bodyPart == "rightarm" or bodyPart == "right arm") then
			hitGroup = HITGROUP_RIGHTARM
		elseif (bodyPart == "leftleg" or bodyPart == "left leg") then
			hitGroup = HITGROUP_LEFTLEG
		elseif (bodyPart == "rightleg" or bodyPart == "right leg") then
			hitGroup = HITGROUP_RIGHTLEG
		elseif (bodyPart == "gear") then
			hitGroup = HITGROUP_GEAR
		else
			ix.util.Notify("Invalid body part specified!", client)
			return
		end

		local damageInfo = DamageInfo()
		damageInfo:SetDamage(amount)
		damageInfo:SetAttacker(client)
		damageInfo:SetInflictor(client:GetActiveWeapon())
		damageInfo:SetDamageType(DMG_BULLET)

		Schema:ScalePlayerDamage(target, hitGroup, damageInfo)

		target:TakeDamageInfo(damageInfo)
	end

	ix.command.Add("CharTakeDamage", COMMAND)
end
