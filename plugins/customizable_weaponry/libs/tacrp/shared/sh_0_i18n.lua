local PLUGIN = PLUGIN
PLUGIN.PhraseTable = PLUGIN.PhraseTable or {}
PLUGIN.STPTable = PLUGIN.STPTable or {}

local lang_cvar = PLUGIN.ConVars["language"]
local gmod_language = GetConVar("gmod_language")

function PLUGIN:GetLanguage()
	if lang_cvar:GetString() ~= "" then
		return string.lower(lang_cvar:GetString())
	end
	local l = gmod_language:GetString()
	return string.lower(l)
end

function PLUGIN:AddPhrase(phrase, str, lang)
	if phrase == nil or phrase == "" or str == nil or str == "" then return nil end
	lang = lang and string.lower(lang) or "en"
	PLUGIN.PhraseTable[lang] = PLUGIN.PhraseTable[lang] or {}
	PLUGIN.PhraseTable[lang][string.lower(phrase)] = str
end

--[[
    Add a "String to Phrase", converting a string to a phrase (i.e. "Assault Rifle" to "class.assaultrifle").
]]
function PLUGIN:AddSTP(phrase, str, lang)
	if phrase == nil or phrase == "" or str == nil or str == "" then return nil end
	PLUGIN.STPTable[string.lower(str)] = phrase
end

function PLUGIN:GetPhrase(phrase, format)
	if phrase == nil or phrase == "" then return nil end
	phrase = string.lower(phrase)
	local lang = PLUGIN:GetLanguage()
	if not lang or not PLUGIN.PhraseTable[lang] or not PLUGIN.PhraseTable[lang][phrase] then
		lang = "en"
	end
	if PLUGIN.PhraseTable[lang] and PLUGIN.PhraseTable[lang][phrase] then
		local str = PLUGIN.PhraseTable[lang][phrase]
		for i, v in pairs(format or {}) do
			str = string.Replace(str, "{" .. i .. "}", v)
		end
		return str
	end
	return nil
end

function PLUGIN:TryTranslate(str)
	if str == nil then return str end
	if PLUGIN.STPTable[string.lower(str)] then
		return PLUGIN:GetPhrase(PLUGIN.STPTable[string.lower(str)])
	end
	return PLUGIN:GetPhrase(str) or str
end

function PLUGIN:GetAttName(att, full)
	local atttbl = PLUGIN.GetAttTable(att)
	if atttbl == {} then return "INVALID ATT" end
	if full then
		return PLUGIN:GetPhrase("att." .. att .. ".name.full")
			or PLUGIN:GetPhrase("att." .. att .. ".name")
			or PLUGIN:GetPhrase(atttbl.FullName)
			or PLUGIN:TryTranslate(atttbl.FullName or atttbl.PrintName)
	else
		return PLUGIN:GetPhrase("att." .. att .. ".name") or PLUGIN:TryTranslate(atttbl.PrintName)
	end
end

function PLUGIN:GetAttDesc(att)
	local atttbl = PLUGIN.GetAttTable(att)
	if atttbl == {} then return "INVALID ATT" end
	return PLUGIN:GetPhrase("att." .. att .. ".desc") or PLUGIN:TryTranslate(atttbl.Description)
end

-- client languages aren't loaded through lua anymore. use gmod's stock localization system instead

function PLUGIN:LoadLanguage(lang)
	local cur_lang = lang or PLUGIN:GetLanguage()

	for _, v in pairs(file.Find("tacrp/shared/langs/*_" .. cur_lang .. ".lua", "LUA")) do
		L = {}
		STL = {}
		include("tacrp/shared/langs/" .. v)
		AddCSLuaFile("tacrp/shared/langs/" .. v)

		local exp = string.Explode("_", string.lower(string.Replace(v, ".lua", "")))

		if not exp[#exp] then
			print("Failed to load TacRP language file " ..
				v .. ", did not get language name (naming convention incorrect?)")
			continue
		elseif not L then
			print("Failed to load TacRP language file " .. v .. ", did not get language table")
			continue
		end

		for phrase, str in pairs(L) do
			PLUGIN:AddPhrase(phrase, str, cur_lang)
		end

		for str, phrase in pairs(STL) do
			PLUGIN:AddSTP(str, phrase)
		end

		if table.Count(L) > 0 then
			hasany = true
		end

		print("Loaded TacRP language file " .. v .. " with " .. table.Count(L) .. " strings.")
		L = nil
		STL = nil
	end
end

function PLUGIN:LoadLanguages()
	PLUGIN.PhraseTable = {}
	PLUGIN.STPTable = {}

	local lang = PLUGIN:GetLanguage()
	PLUGIN:LoadLanguage(lang)
	if lang ~= "en" then
		PLUGIN:LoadLanguage("en")
	end
end

PLUGIN:LoadLanguages()

if CLIENT then
	concommand.Add("tacrp_reloadlangs", function()
		if not LocalPlayer():IsSuperAdmin() then return end

		net.Start("tacrp_reloadlangs")
		net.SendToServer()
	end)

	net.Receive("tacrp_reloadlangs", function(len, ply)
		PLUGIN:LoadLanguages()
		PLUGIN.Regen(true)
	end)
elseif SERVER then
	net.Receive("tacrp_reloadlangs", function(len, ply)
		if not ply:IsSuperAdmin() then return end

		PLUGIN:LoadLanguages()

		net.Start("tacrp_reloadlangs")
		net.Broadcast()
	end)
end
