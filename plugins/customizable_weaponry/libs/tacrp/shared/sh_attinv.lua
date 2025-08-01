local PLUGIN = PLUGIN
function PLUGIN:PlayerGetAtts(ply, att)
	if not IsValid(ply) then return 0 end

	local atttbl = PLUGIN.GetAttTable(att)
	if not atttbl then return 0 end
	if atttbl.InvAtt then att = atttbl.InvAtt end
	if not ply:IsAdmin() and atttbl.AdminOnly then return 0 end
	if atttbl.Free or PLUGIN.ConVars["free_atts"]:GetBool() then return 9999 end
	if engine.ActiveGamemode() == "terrortown" and PLUGIN.ConVars["ttt_bench_freeatts"]:GetBool() and PLUGIN.NearBench(ply) then return 9999 end

	local ret = hook.Run("TacRP_PlayerAttCount", ply, att)
	if ret ~= nil then return ret end

	if not ply.exp_tacrp_AttInv then return 0 end
	if not ply.exp_tacrp_AttInv[att] then return 0 end

	return ply.exp_tacrp_AttInv[att]
end

function PLUGIN:PlayerGiveAtt(ply, att, amt)
	amt = amt or 1

	if not IsValid(ply) then return false end

	if not ply.exp_tacrp_AttInv then ply.exp_tacrp_AttInv = {} end

	local atttbl = PLUGIN.GetAttTable(att)

	if not atttbl then
		print("Invalid att " .. att)
		return false
	end
	if atttbl.Free then return false end -- You can't give a free attachment, silly
	if atttbl.AdminOnly and not (ply:IsPlayer() and ply:IsAdmin()) then return false end
	if atttbl.InvAtt then att = atttbl.InvAtt end

	if PLUGIN.ConVars["free_atts"]:GetBool() then return true end
	local ret = hook.Run("TacRP_PlayerGiveAtt", ply, att, amt)
	if ret ~= nil then return ret end

	if PLUGIN.ConVars["lock_atts"]:GetBool() then
		if ply.exp_tacrp_AttInv[att] == 1 then return end
		ply.exp_tacrp_AttInv[att] = 1
		return true
	else
		ply.exp_tacrp_AttInv[att] = (ply.exp_tacrp_AttInv[att] or 0) + amt
		return true
	end
end

function PLUGIN:PlayerTakeAtt(ply, att, amt)
	amt = amt or 1

	if not IsValid(ply) then return end

	if not ply.exp_tacrp_AttInv then ply.exp_tacrp_AttInv = {} end

	local atttbl = PLUGIN.GetAttTable(att)
	if not atttbl then return false end
	if atttbl.Free then return true end
	if atttbl.InvAtt then att = atttbl.InvAtt end

	if PLUGIN.ConVars["free_atts"]:GetBool() then return true end
	local ret = hook.Run("TacRP_PlayerTakeAtt", ply, att, amt)
	if ret ~= nil then return ret end

	if (ply.exp_tacrp_AttInv[att] or 0) < (PLUGIN.ConVars["lock_atts"]:GetBool() and 1 or amt) then return false end

	if not PLUGIN.ConVars["lock_atts"]:GetBool() then
		ply.exp_tacrp_AttInv[att] = ply.exp_tacrp_AttInv[att] - amt
		if ply.exp_tacrp_AttInv[att] <= 0 then
			ply.exp_tacrp_AttInv[att] = nil
		end
	end
	return true
end

if CLIENT then
	net.Receive("TacRP_sendattinv", function(len, ply)
		LocalPlayer().exp_tacrp_AttInv = {}

		local count = net.ReadUInt(32)

		for i = 1, count do
			local attid = net.ReadUInt(PLUGIN.Attachments_Bits)
			local acount = net.ReadUInt(32)

			local att = PLUGIN.Attachments_Index[attid]

			LocalPlayer().exp_tacrp_AttInv[att] = acount
		end
	end)
elseif SERVER then
	hook.Add("PlayerSpawn", "TacRP_SpawnAttInv", function(ply, trans)
		if trans then return end
		if engine.ActiveGamemode() ~= "terrortown" and PLUGIN.ConVars["loseattsondie"]:GetInt() > 0 then
			ply.exp_tacrp_AttInv = {}
			PLUGIN:PlayerSendAttInv(ply)
		end
	end)

	function PLUGIN:PlayerSendAttInv(ply)
		if PLUGIN.ConVars["free_atts"]:GetBool() then return end
		if not IsValid(ply) then return end
		if not ply.exp_tacrp_AttInv then return end

		net.Start("TacRP_sendattinv")
		net.WriteUInt(table.Count(ply.exp_tacrp_AttInv), 32)
		for att, count in pairs(ply.exp_tacrp_AttInv) do
			local atttbl = PLUGIN.GetAttTable(att)
			local attid = atttbl.ID
			net.WriteUInt(attid, PLUGIN.Attachments_Bits)
			net.WriteUInt(count, 32)
		end
		net.Send(ply)
	end
end
