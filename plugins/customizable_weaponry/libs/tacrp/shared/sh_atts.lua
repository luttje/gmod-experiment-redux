local PLUGIN = PLUGIN
PLUGIN.Attachments = {}
PLUGIN.Attachments_Index = {}

PLUGIN.Attachments_Count = 0

PLUGIN.Attachments_Bits = 16

function PLUGIN.InvalidateCache()
	for _, e in pairs(ents.GetAll()) do
		if e:IsWeapon() and e.ArcticTacRP then
			e:InvalidateCache()
			e:SetBaseSettings()
		end
	end
end

function PLUGIN.LoadAtt(atttbl, shortname, id)
	if atttbl.Ignore then return end

	if ! id then
		PLUGIN.Attachments_Count = PLUGIN.Attachments_Count + 1
		id = PLUGIN.Attachments_Count
	end

	atttbl.ShortName = shortname
	atttbl.ID = id

	PLUGIN.Attachments[shortname] = atttbl
	PLUGIN.Attachments_Index[id] = shortname

	if PLUGIN.ConVars["generateattentities"]:GetBool() and ! atttbl.DoNotRegister and ! atttbl.InvAtt and ! atttbl.Free then
		local attent = {}
		attent.Base = "tacrp_att"
		attent.Icon = atttbl.Icon
		if attent.Icon then
			attent.IconOverride = string.Replace(attent.Icon:GetTexture("$basetexture"):GetName() .. ".png", "0001010",
				"")
		end
		attent.PrintName = atttbl.FullName or atttbl.PrintName or shortname
		attent.Spawnable = true
		attent.AdminOnly = atttbl.AdminOnly or false
		attent.AttToGive = shortname
		attent.Category = "Tactical RP - Attachments"

		scripted_ents.Register(attent, "tacrp_att_" .. shortname)
	end
end

function PLUGIN.LoadAtts()
	PLUGIN.Attachments_Count = 0
	PLUGIN.Attachments = {}
	PLUGIN.Attachments_Index = {}

	local searchdir = PLUGIN.folder .. "/libs/tacrp/shared/atts/"
	local searchdir_bulk = PLUGIN.folder .. "/libs/tacrp/shared/atts_bulk/"

	local files = file.Find(searchdir .. "/*.lua", "LUA")

	for _, filename in pairs(files) do
		AddCSLuaFile(searchdir .. filename)
	end

	files = file.Find(searchdir .. "/*.lua", "LUA")

	for _, filename in pairs(files) do
		if filename == "default.lua" then continue end

		ATT = {}

		local shortname = string.sub(filename, 1, -5)

		include(searchdir .. filename)

		if ATT.Ignore then continue end

		PLUGIN.LoadAtt(ATT, shortname)
	end

	local bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

	for _, filename in pairs(bulkfiles) do
		AddCSLuaFile(searchdir_bulk .. filename)
	end

	bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

	for _, filename in pairs(bulkfiles) do
		if filename == "default.lua" then continue end

		include(searchdir_bulk .. filename)
	end

	PLUGIN.Attachments_Bits = math.min(math.ceil(math.log(PLUGIN.Attachments_Count + 1, 2)), 32)
	hook.Run("TacRP_LoadAtts")

	PLUGIN.InvalidateCache()
end

function PLUGIN.GetAttTable(name)
	local shortname = name
	if isnumber(shortname) then
		shortname = PLUGIN.Attachments_Index[name]
	end

	if PLUGIN.Attachments[shortname] then
		return PLUGIN.Attachments[shortname]
	else
		-- assert(false, "!!!not TacRP tried to access invalid attachment " .. (shortname or "NIL") .. "!!!")
		return {}
	end
end

function PLUGIN.GetAttsForCats(cats)
	if ! istable(cats) then
		cats = { cats }
	end

	local atts = {}

	for i, k in pairs(PLUGIN.Attachments) do
		local attcats = k.Category
		if ! istable(attcats) then
			attcats = { attcats }
		end

		for _, cat in pairs(cats) do
			if table.HasValue(attcats, cat) then
				table.insert(atts, k.ShortName)
				break
			end
		end
	end

	return atts
end

if CLIENT then
	concommand.Add("tacrp_reloadatts", function()
		if ! LocalPlayer():IsSuperAdmin() then return end

		net.Start("tacrp_reloadatts")
		net.SendToServer()
	end)

	net.Receive("tacrp_reloadatts", function(len, ply)
		PLUGIN.LoadAtts()
		PLUGIN.InvalidateCache()
	end)
elseif SERVER then
	net.Receive("tacrp_reloadatts", function(len, ply)
		if ! ply:IsSuperAdmin() then return end

		PLUGIN.LoadAtts()
		PLUGIN.InvalidateCache()

		net.Start("tacrp_reloadatts")
		net.Broadcast()
	end)
end

PLUGIN.Benches = ents.FindByClass("tacrp_bench") or {}
PLUGIN.BenchDistSqr = 128 * 128

function PLUGIN.NearBench(ply)
	local nearbench = false
	for i, ent in pairs(PLUGIN.Benches) do
		if ! IsValid(ent) then
			table.remove(PLUGIN.Benches, i)
			continue
		end
		if ent:GetPos():DistToSqr(ply:GetPos()) <= PLUGIN.BenchDistSqr then
			nearbench = true
			break
		end
	end
	if ! nearbench then return false end
	return true
end

function PLUGIN.CanCustomize(ply, wep, att, slot)
	if engine.ActiveGamemode() == "terrortown" then
		local role = ply:GetTraitor() or ply:IsDetective()

		-- disabled across role
		if (role and ! PLUGIN.ConVars["ttt_cust_role_allow"]:GetBool()) or (! role and ! PLUGIN.ConVars["ttt_cust_inno_allow"]:GetBool()) then
			return false, "Restricted for role"
		end

		-- disabled during round
		if GetRoundState() == ROUND_ACTIVE and ((role and ! PLUGIN.ConVars["ttt_cust_role_round"]:GetBool()) or (! role and ! PLUGIN.ConVars["ttt_cust_inno_round"]:GetBool())) then
			return false, "Restricted during round"
		end

		-- disabled when not near bench
		if ((role and PLUGIN.ConVars["ttt_cust_role_needbench"]:GetBool()) or (! role and PLUGIN.ConVars["ttt_cust_inno_needbench"]:GetBool())) and ! PLUGIN.NearBench(ply) then
			return false, "Requires Customization Bench"
		end
	else
		-- check bench
		if PLUGIN.ConVars["rp_requirebench"]:GetBool() and ! PLUGIN.NearBench(ply) then
			return false, "Restricted during round"
		end
	end

	return true
end

PLUGIN.LoadAtts()
