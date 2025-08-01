local PLUGIN = PLUGIN
hook.Add("CreateMove", "TacRP_CreateMove", function(cmd)
	local wpn = LocalPlayer():GetActiveWeapon()

	-- In TTT ScreenClicker isn't disabled for some reason
	if PLUGIN.CursorEnabled and not LocalPlayer():Alive() then
		PLUGIN.CursorEnabled = false
		gui.EnableScreenClicker(false)
	end

	if not IsValid(wpn) then return end
	if not wpn.ArcticTacRP then return end

	if PLUGIN.ConVars["autoreload"]:GetBool() then
		if wpn:Clip1() == 0 and (wpn:Ammo1() > 0 or wpn:GetInfiniteAmmo())
			and wpn:GetNextPrimaryFire() + 0.5 < CurTime() and wpn:ShouldAutoReload() then
			local buttons = cmd:GetButtons()

			buttons = buttons + IN_RELOAD

			cmd:SetButtons(buttons)
		end
	end

	if PLUGIN.KeyPressed_Melee then
		cmd:AddKey(PLUGIN.IN_MELEE)
	end
end)
