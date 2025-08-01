AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "tacrp_ammo_frag"
ENT.RenderGroup              = RENDERGROUP_TRANSLUCENT

ENT.PrintName                = "Nuclear Device (Ammo)"
ENT.Category                 = "Tactical RP"

ENT.AdminOnly = true
ENT.Spawnable                = true
ENT.Model                    = "models/weapons/tacint/props_misc/briefcase_bomb-1.mdl"

ENT.Ammo = "ti_nuke"

ENT.CollisionSoundsHard = {
    "physics/metal/metal_box_impact_hard1.wav",
    "physics/metal/metal_box_impact_hard2.wav",
    "physics/metal/metal_box_impact_hard3.wav",
}

ENT.CollisionSoundsSoft = {
    "physics/metal/metal_box_impact_soft1.wav",
    "physics/metal/metal_box_impact_soft2.wav",
    "physics/metal/metal_box_impact_soft3.wav",
}