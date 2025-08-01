TacRP.PhraseTable = TacRP.PhraseTable or {}
TacRP.STPTable = TacRP.STPTable or {}

local lang_cvar = TacRP.ConVars["language"]
local gmod_language = GetConVar("gmod_language")

function TacRP:GetLanguage()
    if lang_cvar:GetString() ~= "" then
        return string.lower(lang_cvar:GetString())
    end
    local l = gmod_language:GetString()
    return string.lower(l)
end

function TacRP:AddPhrase(phrase, str, lang)
    if phrase == nil or phrase == "" or str == nil or str == "" then return nil end
    lang = lang and string.lower(lang) or "en"
    TacRP.PhraseTable[lang] = TacRP.PhraseTable[lang] or {}
    TacRP.PhraseTable[lang][string.lower(phrase)] = str
end

--[[
    Add a "String to Phrase", converting a string to a phrase (i.e. "Assault Rifle" to "class.assaultrifle").
]]
function TacRP:AddSTP(phrase, str, lang)
    if phrase == nil or phrase == "" or str == nil or str == "" then return nil end
    TacRP.STPTable[string.lower(str)] = phrase
end

function TacRP:GetPhrase(phrase, format)
    if phrase == nil or phrase == "" then return nil end
    phrase = string.lower(phrase)
    local lang = TacRP:GetLanguage()
    if !lang or !TacRP.PhraseTable[lang] or !TacRP.PhraseTable[lang][phrase] then
        lang = "en"
    end
    if TacRP.PhraseTable[lang] and TacRP.PhraseTable[lang][phrase] then
        local str = TacRP.PhraseTable[lang][phrase]
        for i, v in pairs(format or {}) do
            str = string.Replace(str, "{" .. i .. "}", v)
        end
        return str
    end
    return nil
end

function TacRP:TryTranslate(str)
    if str == nil then return str end
    if TacRP.STPTable[string.lower(str)] then
        return TacRP:GetPhrase(TacRP.STPTable[string.lower(str)])
    end
    return TacRP:GetPhrase(str) or str
end

function TacRP:GetAttName(att, full)
    local atttbl = TacRP.GetAttTable(att)
    if atttbl == {} then return "INVALID ATT" end
    if full then
        return TacRP:GetPhrase("att." .. att .. ".name.full")
                or TacRP:GetPhrase("att." .. att .. ".name")
                or TacRP:GetPhrase(atttbl.FullName)
                or TacRP:TryTranslate(atttbl.FullName or atttbl.PrintName)
    else
        return TacRP:GetPhrase("att." .. att .. ".name") or TacRP:TryTranslate(atttbl.PrintName)
    end
end

function TacRP:GetAttDesc(att)
    local atttbl = TacRP.GetAttTable(att)
    if atttbl == {} then return "INVALID ATT" end
    return TacRP:GetPhrase("att." .. att .. ".desc") or TacRP:TryTranslate(atttbl.Description)
end

-- client languages aren't loaded through lua anymore. use gmod's stock localization system instead

function TacRP:LoadLanguage(lang)
    local cur_lang = lang or TacRP:GetLanguage()

    for _, v in pairs(file.Find("tacrp/shared/langs/*_" .. cur_lang .. ".lua", "LUA")) do

        L = {}
        STL = {}
        include("tacrp/shared/langs/" .. v)
        AddCSLuaFile("tacrp/shared/langs/" .. v)

        local exp = string.Explode("_", string.lower(string.Replace(v, ".lua", "")))

        if !exp[#exp] then
            print("Failed to load TacRP language file " .. v .. ", did not get language name (naming convention incorrect?)")
            continue
        elseif !L then
            print("Failed to load TacRP language file " .. v .. ", did not get language table")
            continue
        end

        for phrase, str in pairs(L) do
            TacRP:AddPhrase(phrase, str, cur_lang)
        end

        for str, phrase in pairs(STL) do
            TacRP:AddSTP(str, phrase)
        end

        if table.Count(L) > 0 then
            hasany = true
        end

        print("Loaded TacRP language file " .. v .. " with " .. table.Count(L) .. " strings.")
        L = nil
        STL = nil
    end
end

function TacRP:LoadLanguages()
    TacRP.PhraseTable = {}
    TacRP.STPTable = {}

    local lang = TacRP:GetLanguage()
    TacRP:LoadLanguage(lang)
    if lang ~= "en" then
        TacRP:LoadLanguage("en")
    end
end

TacRP:LoadLanguages()

if CLIENT then

    concommand.Add("tacrp_reloadlangs", function()
        if !LocalPlayer():IsSuperAdmin() then return end

        net.Start("tacrp_reloadlangs")
        net.SendToServer()
    end)

    net.Receive("tacrp_reloadlangs", function(len, ply)
        TacRP:LoadLanguages()
        TacRP.Regen(true)
    end)
elseif SERVER then
    net.Receive("tacrp_reloadlangs", function(len, ply)
        if !ply:IsSuperAdmin() then return end

        TacRP:LoadLanguages()

        net.Start("tacrp_reloadlangs")
        net.Broadcast()
    end)
end