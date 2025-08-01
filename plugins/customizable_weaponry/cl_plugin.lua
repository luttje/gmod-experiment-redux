local PLUGIN = PLUGIN

-- Overriden lua/tacrp/client/cl_bind.lua to remove complaints
function PLUGIN.GetBind(binding)
	local bind = input.LookupBinding(binding)

	if not bind then
		return "!"
	end

	return string.upper(bind)
end

-- This removes autoreloading and melee attacks with weapons (which would require binding +tacrp_melee)
hook.Remove("CreateMove", "TacRP_CreateMove")

-- Remove the hook so flashlight glares don't draw
hook.Remove("PostDrawTranslucentRenderables", "TacRP_TranslucentDraw")

function PLUGIN:ShowCompatibleItems(attachmentId)
	local window = vgui.Create("expAttachmentList")
	window:Populate(attachmentId)
end

-- Copied from TacRP to draw everything but the flashlight glare
function PLUGIN:PostDrawTranslucentRenderables()
	for _, client in pairs(player.GetAll()) do
		local activeWeapon = client:GetActiveWeapon()

		if (not IsValid(activeWeapon) or not activeWeapon.ArcticTacRP) then
			continue
		end

		if (client == LocalPlayer() and GetViewEntity() == client) then
			continue
		end

		activeWeapon:DrawLasers(true)
		activeWeapon:DrawFlashlightsWM() -- Only draws for the owner
		-- wep:DrawFlashlightGlares() -- too bright!
		activeWeapon:DoScopeGlint()

		self:DrawFlashlights(activeWeapon)
	end
end

-- local flashlightMaterial = Material("experiment-redux/sprites/flashlight")

-- TODO: Draw flashlight beams for everyone
function PLUGIN:DrawFlashlights(weapon)
	-- 	local owner = weapon:GetOwner()

	-- 	if (not IsValid(owner)) then
	-- 		return
	-- 	end

	-- 	-- Check if they have the flashlight enabled
	-- 	if (not weapon:GetNWTactical()) then
	-- 		return
	-- 	end

	-- 	local eyePos = owner:EyePos()
	-- 	local forward = owner:EyeAngles():Forward()

	-- 	render.SetMaterial(flashlightMaterial)

	-- 	for _, attachmentSlot in ipairs(weapon.Attachments) do
	-- 		if (not attachmentSlot.Installed) then
	-- 			continue
	-- 		end

	-- 		if (not weapon.expCachedSlotIsFlashlight or weapon.expCachedSlotIsFlashlight[attachmentSlot.Installed] == nil) then
	-- 			weapon.expCachedSlotIsFlashlight = weapon.expCachedSlotIsFlashlight or {}
	-- 			weapon.expCachedSlotIsFlashlight[attachmentSlot.Installed] = PLUGIN.GetAttTable(attachmentSlot.Installed).Flashlight == true
	-- 		end

	-- 		local isFlashlight = weapon.expCachedSlotIsFlashlight[attachmentSlot.Installed]

	-- 		if (not isFlashlight) then
	-- 			continue
	-- 		end

	-- 		local pos = eyePos

	--         local trace = util.TraceLine({
	--             start = eyePos,
	--             endpos = eyePos + forward * 128,
	--             mask = MASK_OPAQUE,
	--             filter = LocalPlayer(),
	--         })

	-- 		pos = trace.HitPos
	-- 		size = trace.Fraction * 128

	-- 		render.DrawSprite(pos, size, size, color_white)
	-- 	end
end

-- not Workaround for TacRP incorrectly retrying to get the networked weapon entity (using a NULL entity which always has the same index 0)
local MAX_EDICT_BITS = 13
net.Receive("tacrp_networkweapon", function(len)
	-- local wpn = net.ReadEntity() -- May fail and thus lose the ent index we are waiting for
	local entIndex = net.ReadUInt(MAX_EDICT_BITS)

	if (not entIndex) then
		return
	end

	local weapon = Entity(entIndex)

	-- When the server immediately calls NetworkWeapon on a new weapon,
	-- the client entity may not be valid or correct instantly.
	-- (in SP, the entity will appear valid but the functions/variables will all be nil.)
	if (not IsValid(weapon) or not weapon.ArcticTacRP) then
		local retryTimerName = "tacrpWeaponsWait" .. engine.TickCount() .. Schema.util.GetUniqueID()

		local ids = {}
		for i = 1, (len - MAX_EDICT_BITS) / PLUGIN.Attachments_Bits do
			table.insert(ids, net.ReadUInt(PLUGIN.Attachments_Bits))
		end

		local retries = 0

		timer.Create(retryTimerName, 0, 0, function()
			weapon = Entity(entIndex)

			if (not IsValid(weapon) or not weapon.ArcticTacRP) then
				retries = retries + 1

				if (retries > 10000) then
					timer.Remove(retryTimerName)
				end

				return
			end

			timer.Remove(retryTimerName)

			weapon:ReceiveWeapon(ids)
			weapon:UpdateHolster()
		end)
	else
		weapon:ReceiveWeapon()
		weapon:UpdateHolster()
	end
end)
