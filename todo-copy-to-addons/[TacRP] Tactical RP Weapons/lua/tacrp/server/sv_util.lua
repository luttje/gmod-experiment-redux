local badseqs = {
    ["Unknown"] = true, -- no cower sequence
    ["head_pitch"] = true, -- antlion guards
}

function TacRP.Flashbang(ent, pos, radius, time_max, time_min, time_stunadd)
    time_stunadd = time_stunadd or 0.5
    for _, k in ipairs(ents.FindInSphere(pos, radius)) do
        if k:IsPlayer() then
            local dist = k:EyePos():Distance(pos)
            local dp = (k:EyePos() - pos):Dot(k:EyeAngles():Forward())

            local time = Lerp( dp, time_max, time_min )

            time = Lerp( dist / radius, time, time_min )

            local tr = util.QuickTrace(pos, k:EyePos() - pos, {k, ent})

            if tr.Fraction < 1 then
                time = 0
            else
                local wep = k:GetActiveWeapon()
                if IsValid(wep) and wep.ArcticTacRP and wep:GetValue("StunResist") then
                    time = math.sqrt(time) * 0.5
                    time_stunadd = math.sqrt(time_stunadd) * 0.5
                end

                k:SetNWFloat("TacRPStunStart", CurTime())
                k:SetNWFloat("TacRPStunDur", time + time_stunadd)
            end

            net.Start("tacrp_flashbang")
                net.WriteFloat(time)
            net.Send(k)
        elseif k:IsNPC() then


            -- stun them if they have a good cower sequence. this doesn't affect npcs like antlion guards, manhacks etc.
            if badseqs[k:GetSequenceName(ACT_COWER)] != true then
                local tr = util.TraceLine({
                    start = pos,
                    endpos = k:EyePos(),
                    mask = MASK_SOLID,
                    filter = {ent, k}
                })
                if tr.Fraction == 1 then
                    k:SetSchedule(SCHED_COWER)
                    k:RestartGesture(ACT_COWER)
                    k:SetNPCState(NPC_STATE_NONE)
                    k.TacRP_FlashEnd = CurTime() + time_max + time_stunadd - 0.01
                    timer.Simple(time_max + time_stunadd, function()
                        if IsValid(k) and k:IsNPC() and k.TacRP_FlashEnd <= CurTime() then
                            k:SetNPCState(NPC_STATE_ALERT)
                        end
                    end)
                end
            end
        end
    end
end

TacRP.WeaponListCache = {}
function TacRP.GetWeaponList(subcat, tier)
    if !subcat then subcat = "" end
    if !tier then tier = "" end
    if !TacRP.WeaponListCache[subcat] or !TacRP.WeaponListCache[subcat][tier] then
        TacRP.WeaponListCache[subcat] = TacRP.WeaponListCache[subcat] or {}
        TacRP.WeaponListCache[subcat][tier] = {}

        for i, wep in pairs(weapons.GetList()) do
            local weap = weapons.Get(wep.ClassName)
            if !weap or !weap.ArcticTacRP
                    or wep.ClassName == "tacrp_base" or wep.ClassName == "tacrp_base_nade" or wep.ClassName == "tacrp_base_melee"
                    or !weap.Spawnable or weap.AdminOnly
                    or (subcat == "npc" and !weap.NPCUsable)
                    or (subcat != "" and subcat != "npc" and subcat != weap.SubCatType)
                    or (tier != "" and tier != weap.SubCatTier) then
                continue
            end

            table.insert(TacRP.WeaponListCache[subcat][tier], wep.ClassName)
        end
    end
    return TacRP.WeaponListCache[subcat][tier]
end

function TacRP.GetRandomWeapon(subcat, tier)
    if !subcat then subcat = "" end
    if !tier then tier = "" end

    local tbl = TacRP.GetWeaponList(subcat, tier)
    return tbl[math.random(1, #tbl)]
end