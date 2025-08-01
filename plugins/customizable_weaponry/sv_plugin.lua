local PLUGIN = PLUGIN

-- Commented because we include our own version of TacRP without grenade menu and broken hands.
-- [TacRP] Tactical RP Weapons (https://steamcommunity.com/sharedfiles/filedetails/?id=2588031232)
-- resource.AddWorkshop("2588031232")

-- [TacRP] Brute Force Melee Pack (https://steamcommunity.com/sharedfiles/filedetails/?id=3009874388)
resource.AddWorkshop("3009874388")

-- TODO: Optionally add more weapons: https://steamcommunity.com/workshop/filedetails/?id=3006509287

if (not TacRP) then
	ix.util.SchemaErrorNoHaltWithStack("TacRP is not installed or enabled! Expect errors!")
end

if (not ix.util.IsAddonMounted("3009874388")) then
	ix.util.SchemaErrorNoHaltWithStack("Brute Force Melee Pack is not installed or enabled! Expect errors!")
end

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

function PLUGIN:PlayerHasFlashlight(client)
	local weapon = client:GetActiveWeapon()

	if (not IsValid(weapon) or not weapon.ArcticTacRP) then
		return
	end

	for _, attachmentSlot in ipairs(weapon.Attachments) do
		if (not attachmentSlot.Installed) then
			continue
		end

		if (attachmentSlot.Installed == "tac_flashlight") then
			client:AllowFlashlight(true)
			return true
		end
	end
end

-- Removed because its ugly, let's draw the flashlight for others manually
-- function PLUGIN:WeaponEquip(weapon, client)
-- 	if (not weapon.ArcticTacRP) then
-- 		return
-- 	end

--     -- Callback when the user toggles the tactical state
-- 	weapon:NetworkVarNotify("NWTactical", function(weapon, name, oldValue, newValue)
-- 		for _, attachmentSlot in pairs(weapon.Attachments) do
-- 			if not attachmentSlot.Installed then
-- 				continue
-- 			end

-- 			local attachment = TacRP.GetAttTable(attachmentSlot.Installed)

-- 			-- Also toggle the real flashlight so other players see it
-- 			if (attachment.Flashlight) then
-- 				-- client:Flashlight(newValue)
-- 			end
-- 		end
-- 	end)
-- end
