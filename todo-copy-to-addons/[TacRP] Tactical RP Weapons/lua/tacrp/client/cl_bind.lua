hook.Add("PlayerBindPress", "TacRP_Binds", function(ply, bind, pressed, code)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP then return end

    -- if we don't block, TTT will do radio menu
    if engine.ActiveGamemode() == "terrortown" and bind == "+zoom" and !LocalPlayer():KeyDown(IN_USE) then
        ply.TacRPBlindFireDown = pressed
        return true
    end

    if bind == "+showscores" then
        wpn.LastHintLife = CurTime() -- ping the hints
    end

    if !pressed then return end

    if bind == "+menu_context" and !LocalPlayer():KeyDown(IN_USE) then
        if wpn:GetScopeLevel() == 0 then
            net.Start("TacRP_togglecustomize")
            net.WriteBool(!wpn:GetCustomize())
            net.SendToServer()
        elseif !TacRP.ConVars["togglepeek"]:GetBool() then
            net.Start("tacrp_togglepeek")
            net.WriteBool(true) -- release is handled in sh_scope
            net.SendToServer()
        else
            net.Start("tacrp_togglepeek")
            net.WriteBool(!wpn:GetPeeking())
            net.SendToServer()
        end

        return true
    end

    if TacRP.ConVars["toggletactical"]:GetBool() and bind == "impulse 100" and wpn:GetValue("CanToggle") and (
                !GetConVar("mp_flashlight"):GetBool() or (TacRP.ConVars["flashlight_alt"]:GetBool() and ply:KeyDown(IN_WALK))
                or (!TacRP.ConVars["flashlight_alt"]:GetBool() and !ply:KeyDown(IN_WALK))) then
        net.Start("tacrp_toggletactical")
        net.SendToServer()
        wpn:SetTactical(!wpn:GetTactical())

        surface.PlaySound("tacrp/firemode.wav")
        return true -- we dont want hl2 flashlight
     end
end)

TacRP.Complaints = {}

function TacRP.GetBind(binding)
    local bind = input.LookupBinding(binding)

    if !bind then
        if !TacRP.Complaints[binding] then
            TacRP.Complaints[binding] = true

            if binding == "grenade1" or binding == "grenade2" then
                LocalPlayer():PrintMessage(HUD_PRINTTALK, "Bind +grenade1 and +grenade2 to use TacRP quick grenades!")
            end
        end
        return "!"
    end

    return string.upper(bind)
end

function TacRP.GetBindKey(bind)
    local key = input.LookupBinding(bind)
    if !key then
        return bind
    else
        return string.upper(key)
    end
end

function TacRP.GetKeyIsBound(bind)
    local key = input.LookupBinding(bind)

    if !key then
        return false
    else
        return true
    end
end

function TacRP.GetKey(bind)
    local key = input.LookupBinding(bind)

    return key and input.GetKeyCode(key)
end

TacRP.KeyPressed_Melee = false

concommand.Add("+tacrp_melee", function()
    TacRP.KeyPressed_Melee = true
end)

concommand.Add("-tacrp_melee", function()
    TacRP.KeyPressed_Melee = false
end)