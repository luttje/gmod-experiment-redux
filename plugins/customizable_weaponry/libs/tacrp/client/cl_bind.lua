local PLUGIN = PLUGIN
hook.Add("PlayerBindPress", "TacRP_Binds", function(ply, bind, pressed, code)
	local wpn = ply:GetActiveWeapon()

	if not wpn or not IsValid(wpn) or not wpn.ArcticTacRP then return end

	-- if we don't block, TTT will do radio menu
	if engine.ActiveGamemode() == "terrortown" and bind == "+zoom" and not LocalPlayer():KeyDown(IN_USE) then
		ply.TacRPBlindFireDown = pressed
		return true
	end

	if bind == "+showscores" then
		wpn.LastHintLife = CurTime() -- ping the hints
	end

	if not pressed then return end

	if bind == "+menu_context" and not LocalPlayer():KeyDown(IN_USE) then
		if wpn:GetScopeLevel() == 0 then
			net.Start("TacRP_togglecustomize")
			net.WriteBool(not wpn:GetCustomize())
			net.SendToServer()
		elseif not PLUGIN.ConVars["togglepeek"]:GetBool() then
			net.Start("tacrp_togglepeek")
			net.WriteBool(true) -- release is handled in sh_scope
			net.SendToServer()
		else
			net.Start("tacrp_togglepeek")
			net.WriteBool(not wpn:GetPeeking())
			net.SendToServer()
		end

		return true
	end

	if PLUGIN.ConVars["toggletactical"]:GetBool() and bind == "impulse 100" and wpn:GetValue("CanToggle") and (
			not GetConVar("mp_flashlight"):GetBool() or (PLUGIN.ConVars["flashlight_alt"]:GetBool() and ply:KeyDown(IN_WALK))
			or (not PLUGIN.ConVars["flashlight_alt"]:GetBool() and not ply:KeyDown(IN_WALK))) then
		net.Start("tacrp_toggletactical")
		net.SendToServer()
		wpn:SetTactical(not wpn:GetTactical())

		surface.PlaySound("tacrp/firemode.wav")
		return true -- we dont want hl2 flashlight
	end
end)

PLUGIN.Complaints = {}

function PLUGIN.GetBind(binding)
	local bind = input.LookupBinding(binding)

	if not bind then
		if not PLUGIN.Complaints[binding] then
			PLUGIN.Complaints[binding] = true

			if binding == "grenade1" or binding == "grenade2" then
				LocalPlayer():PrintMessage(HUD_PRINTTALK, "Bind +grenade1 and +grenade2 to use TacRP quick grenades!")
			end
		end
		return "!"
	end

	return string.upper(bind)
end

function PLUGIN.GetBindKey(bind)
	local key = input.LookupBinding(bind)
	if not key then
		return bind
	else
		return string.upper(key)
	end
end

function PLUGIN.GetKeyIsBound(bind)
	local key = input.LookupBinding(bind)

	if not key then
		return false
	else
		return true
	end
end

function PLUGIN.GetKey(bind)
	local key = input.LookupBinding(bind)

	return key and input.GetKeyCode(key)
end

PLUGIN.KeyPressed_Melee = false

concommand.Add("+tacrp_melee", function()
	PLUGIN.KeyPressed_Melee = true
end)

concommand.Add("-tacrp_melee", function()
	PLUGIN.KeyPressed_Melee = false
end)
