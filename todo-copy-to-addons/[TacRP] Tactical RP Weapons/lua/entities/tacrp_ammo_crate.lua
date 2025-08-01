AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "tacrp_ammo"
ENT.RenderGroup              = RENDERGROUP_TRANSLUCENT

ENT.PrintName                = "Ammo Crate"
ENT.Category                 = "Tactical RP"

ENT.Spawnable                = true
ENT.Model                    = "models/weapons/tacint/ammoboxes/ammo_box-2b.mdl"

ENT.InfiniteUse = true
ENT.OpeningAnim = true

ENT.AutomaticFrameAdvance = true

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