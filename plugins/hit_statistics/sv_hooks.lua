local PLUGIN = PLUGIN

function PLUGIN:DatabaseConnected()
	local query

	-- Table to store player statistics
	query = mysql:Create("exp_player_hit_stats")
	query:Create("stat_id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
	query:Create("character_id", "INT(11) UNSIGNED NOT NULL")
	query:Create("steam_id", "VARCHAR(20) NOT NULL")
	query:Create("victim_character_id", "INT(11) UNSIGNED")
	query:Create("hitgroup", "INT(11) UNSIGNED")
	query:Create("weapon_class", "VARCHAR(64)")
	query:Create("damage", "FLOAT")
	query:Create("distance", "FLOAT")
	query:Create("stat_type", "VARCHAR(32) NOT NULL") -- 'hit', 'shot_fired', 'kill', 'death', etc.
	query:Create("value", "INT(11) UNSIGNED DEFAULT 1")
	query:Create("created_at", "INT(11) UNSIGNED NOT NULL")
	query:PrimaryKey("stat_id")
	query:Execute()
end

function PLUGIN:OnWipeTables()
	local query

	query = mysql:Drop("exp_player_hit_stats")
	query:Execute()
end

function PLUGIN:PostEntityFireBullets(entity, bulletInfo)
	if (not entity:IsPlayer()) then
		return
	end

	local weapon = entity:GetActiveWeapon()

	if (not IsValid(weapon)) then
		return
	end

	-- Even if a weapon fires multiple shots, it would do it all this frame. The 0 delay
	-- will allow only 1 shot to be tracked per frame
	if (Schema.util.Throttle("shotFiredTracker", 0, entity)) then
		return
	end

	self:IncrementStat(entity, "shots_fired", 1)
end

-- Track damage dealt to other players with body part information
function PLUGIN:ScalePlayerDamage(target, hitgroup, damageInfo)
	local attacker = damageInfo:GetAttacker()

	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	-- Don't track self-damage
	if (attacker == target) then
		return
	end

	local damage = damageInfo:GetDamage()
	local weapon = damageInfo:GetInflictor()
	local weaponClass = IsValid(weapon) and weapon:GetClass() or "unknown"

	self:RecordHit(attacker, {
		victim = target,
		damage = damage,
		hitgroup = hitgroup,
		weapon = weaponClass,
		distance = attacker:GetPos():Distance(target:GetPos()),
		timestamp = os.time()
	})
end

-- Track when players are killed (for kill/death ratios)
function PLUGIN:PlayerDeath(victim, inflictor, attacker)
	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	if (not IsValid(victim) or not victim:IsPlayer()) then
		return
	end

	-- Don't track suicide
	if (attacker == victim) then
		return
	end

	self:IncrementStat(attacker, "kills", 1)
	self:IncrementStat(victim, "deaths", 1)

	-- Check if it was a headshot kill
	local hitgroup = victim:LastHitGroup() or HITGROUP_GENERIC
	if (hitgroup == HITGROUP_HEAD) then
		self:IncrementStat(attacker, "headshot_kills", 1)
	end
end
