do
	local COMMAND = {}

	COMMAND.description = "Search the tied character you are looking at."

	function COMMAND:OnRun(client)
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
			client:Notify("You must look at a character!")
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
			client:Notify("This character is dead!")
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
			client:Notify("Invalid body part specified!")
			return
		end

		local inflictor = client:GetActiveWeapon()
		local damageType = DMG_BULLET

		if (inflictor and inflictor.MeleeDamageType) then
			damageType = inflictor.MeleeDamageType
		end

		local damageInfo = DamageInfo()
		damageInfo:SetDamage(amount)
		damageInfo:SetAttacker(client)
		damageInfo:SetInflictor(inflictor)
		damageInfo:SetDamageType(damageType)

		Schema:ScalePlayerDamage(target, hitGroup, damageInfo)

		target:TakeDamageInfo(damageInfo)

		client:Notify("You have damaged " .. target:GetName() .. "'s " .. bodyPart .. " for " .. amount .. " damage.")
	end

	ix.command.Add("CharTakeDamage", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Bump the entity position you are looking at towards where you are looking."
	COMMAND.arguments = {
		bit.bor(ix.type.number, ix.type.optional)
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, amount)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 1000
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (not IsValid(target)) then
			client:Notify("You must look at a valid entity!")
			return
		end

		target:SetPos(target:GetPos() + client:GetAimVector() * (amount or 10))
	end

	ix.command.Add("EntityBump", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove entities of a certain class within a radius around you."
	COMMAND.arguments = {
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional)
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, class, radius)
		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target)) then
			if (target:IsPlayer()) then
				client:Notify("You must look at an entity, not a player!")
				return
			end

			class = target:GetClass()
		end

		local entities = ents.FindInSphere(client:GetPos(), radius or 256)
		local count = 0

		for _, entity in ipairs(entities) do
			if (entity:GetClass() == class) then
				count = count + 1
				entity:Remove()
			end
		end

		client:Notify("Removed " .. count .. " entities of class '" .. class .. "'.")
	end

	ix.command.Add("EntityRemove", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Spawn an NPC with the NPC config based on the id you provide."
	COMMAND.arguments = {
		ix.type.string,
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, npcID)
		local npc = Schema.npc.Get(npcID)

		if (not npc) then
			client:Notify("Invalid NPC ID!")
			return
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local trace = util.TraceLine(data)

		local angledTowardsPlayer = (client:GetPos() - trace.HitPos):Angle()
		angledTowardsPlayer.p = 0

		-- Spawn slightly above the ground so legs don't glitch
		Schema.npc.SpawnEntity(npc, trace.HitPos + trace.HitNormal * 4, angledTowardsPlayer)

		client:Notify("NPC spawned successfully.")
	end

	ix.command.Add("NpcSpawn", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove the NPC you are looking at."
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client)
		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:GetClass() == "exp_npc") then
			target:Remove()
			client:Notify("NPC removed successfully.")
		else
			client:Notify("You must look at an NPC!")
		end
	end

	ix.command.Add("NpcRemove", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Applies a buff to yourself or the character you are looking at."
	COMMAND.arguments = {
		ix.type.string,
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, buffUniqueID)
		if (not Schema.buff.Exists(buffUniqueID)) then
			client:Notify("Invalid Buff Unique ID!")
			return
		end

		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer()) then
			client:Notify("Buff applied to " .. target:GetName() .. ".")
		else
			target = client
			client:Notify("Buff applied to yourself.")
		end

		Schema.buff.SetActive(target, buffUniqueID)
	end

	ix.command.Add("CharBuffActivate", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Immediately removes all buffs of a certain type from yourself or the character you are looking at."
	COMMAND.arguments = {
		ix.type.string,
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, buffUniqueID)
		if (not Schema.buff.Exists(buffUniqueID)) then
			client:Notify("Invalid Buff Unique ID!")
			return
		end

		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity

		if (not IsValid(target) or not target:IsPlayer()) then
			target = client
		end

		local expiredCount = Schema.buff.CheckExpired(target, function(client, buffTable, buff)
			return buffTable.uniqueID == buffUniqueID
		end)

		client:Notify("Removed " .. expiredCount .. " buffs of type '" .. buffUniqueID .. "' from " .. target:GetName() .. ".")
	end

	ix.command.Add("CharBuffExpire", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Bring the given character to where you are looking."
	COMMAND.arguments = {
		ix.type.character
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target)
		target = target:GetPlayer()

		target:SetPos(client:GetEyeTraceNoCursor().HitPos)

		client:Notify("You have brought " .. target:GetName() .. " to your location.")
	end

	ix.command.Add("CharBring", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Give the specified character a perk."
	COMMAND.arguments = {
		ix.type.character,
		ix.type.string
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, perkUniqueID)
        local perkTable = Schema.perk.Get(perkUniqueID)

		if (not perkTable) then
			client:Notify("Invalid Perk Unique ID!")
			return
		end

		Schema.perk.Give(target:GetPlayer(), perkUniqueID)
		client:Notify("You have given " .. target:GetName() .. " the '" .. perkTable.name .. "' perk.")
	end

	ix.command.Add("CharPerkGive", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove the specified perk from the given character."
	COMMAND.arguments = {
		ix.type.character,
		ix.type.string
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, perkUniqueID)
        local perkTable = Schema.perk.Get(perkUniqueID)

		if (not perkTable) then
			client:Notify("Invalid Perk Unique ID!")
			return
		end

		Schema.perk.Take(target:GetPlayer(), perkUniqueID)
		client:Notify("You have removed the '" .. perkTable.name .. "' perk from " .. target:GetName() .. ".")
	end

	ix.command.Add("CharPerkRemove", COMMAND)
end
