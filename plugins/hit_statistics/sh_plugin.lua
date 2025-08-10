local PLUGIN = PLUGIN

PLUGIN.name = "Hit Statistics"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Tracks body part hit statistics."

PLUGIN.dependantTables = {
	"ix_characters",
	"ix_players",
	"exp_player_hit_stats",
}

-- Body part mappings for Source Engine hitgroups
PLUGIN.hitgroupNames = {
	[HITGROUP_GENERIC] = "Generic",
	[HITGROUP_HEAD] = "Head",
	[HITGROUP_CHEST] = "Chest",
	[HITGROUP_STOMACH] = "Stomach",
	[HITGROUP_LEFTARM] = "Left Arm",
	[HITGROUP_RIGHTARM] = "Right Arm",
	[HITGROUP_LEFTLEG] = "Left Leg",
	[HITGROUP_RIGHTLEG] = "Right Leg",
	[HITGROUP_GEAR] = "Gear",
}

-- Register our chunked messages (this auto-sets up receivers on client)
Schema.chunkedNetwork.Register("PlayerHitStats", 30, 0.03)
Schema.chunkedNetwork.Register("SuspiciousPlayers", 50, 0.05)
Schema.chunkedNetwork.Register("PlayersOverview", 50, 0.05)

ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")
