local PLUGIN = PLUGIN

-- [TacRP] Tactical RP Weapons (https://steamcommunity.com/sharedfiles/filedetails/?id=2588031232)
resource.AddWorkshop("2588031232")

-- TODO: Optionally add more weapons: https://steamcommunity.com/workshop/filedetails/?id=3006509287

-- TODO: Add melee weapons: https://steamcommunity.com/sharedfiles/filedetails/?id=3009874388

-- We override this so TacRP doesnt interfere with our own door busting
function TacRP.DoorBust(ent, vel, attacker)
end

net.Receive("tacrp_givenadewep", function(len, ply)
    local bf = net.ReadUInt(TacRP.QuickNades_Bits)
	-- We override this so players cant quick nade
end)

net.Receive("tacrp_togglenade", function(len, ply)
    local bf = net.ReadUInt(TacRP.QuickNades_Bits)
	-- We override this so players cant quick nade
end)

net.Receive("tacrp_toggleblindfire", function(len, ply)
    local bf = net.ReadUInt(TacRP.BlindFireNetBits)
	-- We override this, because I don't know what it does.
end)

net.Receive("tacrp_togglecustomize", function(len, ply)
    local bf = net.ReadBool()
	-- We override this so players cant open the customize menu.
end)

net.Receive("tacrp_attach", function(len, ply)
    local wpn = net.ReadEntity()

    local attach = net.ReadBool()
    local slot = net.ReadUInt(8)
    local attid = 0

    if attach then
        attid = net.ReadUInt(TacRP.Attachments_Bits)
    end

	-- We override this so players cant attach/detach attachments.
end)

net.Receive("tacrp_receivepreset", function(len, ply)
    local wpn = net.ReadEntity()

	-- We override this so players cant receive presets.
end)
