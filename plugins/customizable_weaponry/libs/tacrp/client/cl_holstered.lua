local PLUGIN = PLUGIN
hook.Add("PostPlayerDraw", "TacRP_Holster", function(ply, flags)
	if not ply.exp_tacrp_Holster or bit.band(flags, STUDIO_RENDER) ~= STUDIO_RENDER then return end
	if ply == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then return end

	if not PLUGIN.ConVars["drawholsters"]:GetBool() or not PLUGIN.ConVars["visibleholster"]:GetBool() then return end

	ply.exp_tacrp_HolsterModels = ply.exp_tacrp_HolsterModels or {}
	for i, v in ipairs(PLUGIN.HolsterBones) do
		local wep = ply.exp_tacrp_Holster[i]
		if not IsValid(wep) or wep:GetOwner() ~= ply or wep == ply:GetActiveWeapon() or not wep:GetValue("HolsterVisible") then
			SafeRemoveEntity(ply.exp_tacrp_HolsterModels[i])
			ply.exp_tacrp_HolsterModels[i] = nil
			ply.exp_tacrp_Holster[i] = nil
			continue
		end

		local bone = ply:LookupBone(v[1])
		local matrix = bone and ply:GetBoneMatrix(bone)
		if not bone or not matrix then return end

		local fallback
		local holstermodel = wep:GetValue("HolsterModel") or wep.WorldModel
		if not util.IsValidModel(holstermodel) and v[3] then
			holstermodel = v[3][1]
			fallback = true
		end

		if not ply.exp_tacrp_HolsterModels[i] or not IsValid(ply.exp_tacrp_HolsterModels[i])
			or ply.exp_tacrp_HolsterModels[i]:GetModel() ~= holstermodel then
			SafeRemoveEntity(ply.exp_tacrp_HolsterModels[i])
			ply.exp_tacrp_HolsterModels[i] = ClientsideModel(holstermodel, RENDERGROUP_OPAQUE)
			ply.exp_tacrp_HolsterModels[i]:SetNoDraw(true)
		end

		local spos, sang = v[2], Angle()
		if istable(v[2]) then
			spos = v[2][1]
			sang = v[2][2]
		elseif v[2] == nil then
			spos = Vector()
		end

		local hpos, hang = wep:GetValue("HolsterPos"), wep:GetValue("HolsterAng")
		if fallback then
			hpos = v[3][2]
			hang = v[3][3]
		end
		local off = spos + hpos
		local rot = hang + sang

		local pos = matrix:GetTranslation()
		local ang = matrix:GetAngles()

		pos = pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z
		ang:RotateAroundAxis(ang:Forward(), rot.p)
		ang:RotateAroundAxis(ang:Up(), rot.y)
		ang:RotateAroundAxis(ang:Right(), rot.r)

		debugoverlay.Axis(pos, ang, 8, FrameTime() * 2, true)

		model = ply.exp_tacrp_HolsterModels[i]
		model:SetPos(pos)
		model:SetAngles(ang)
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:DrawModel()
		model:SetRenderOrigin()
		model:SetRenderAngles()

		if not wep:GetValue("HolsterModel") then
			wep:DoBodygroups(true, model)
			wep:DrawCustomModel(true, ply.exp_tacrp_HolsterModels[i])
		end
	end
end)

PLUGIN.ClientSmokeCache = {}

hook.Add("HUDDrawTargetID", "TacRP_FlashlightGlint", function()
	local ply = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(ply) then return end

	-- Flashed
	if LocalPlayer():GetNWFloat("TacRPStunStart", 0) + LocalPlayer():GetNWFloat("TacRPStunDur", 0) > CurTime() then return false end

	-- Flashlight glint
	if ply:IsPlayer() and PLUGIN.ConVars["flashlight_blind"]:GetBool() then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.ArcticTacRP and wep:GetValue("Flashlight") then
			local src, dir = wep:GetTracerOrigin(), wep:GetShootDir()

			local diff = EyePos() - src

			local dot = -dir:Forward():Dot(EyeAngles():Forward())
			local dot2 = dir:Forward():Dot(diff:GetNormalized())
			dot = math.max(0, (dot + dot2) / 2) ^ 1.5
			if dot > 0.707 then
				local dist = 300
				local wep2 = LocalPlayer():GetActiveWeapon()
				if IsValid(wep2) and wep2.ArcticTacRP and wep2:IsInScope() and wep2:GetValue("ScopeOverlay") then
					dist = 3500
				end
				if wep:GetTracerOrigin():Distance(EyePos()) <= dist then
					return false
				end
			end
		end
	end


	-- Smoke
	for i, ent in ipairs(PLUGIN.ClientSmokeCache) do
		if not IsValid(ent) or not ent.TacRPSmoke then
			table.remove(PLUGIN.ClientSmokeCache, i)
			continue
		end
		local pos = ent:GetPos()
		local rad = ent.SmokeRadius

		-- target is in smoke
		if ply:WorldSpaceCenter():Distance(pos) <= rad then return false end

		local s = ply:WorldSpaceCenter() - EyePos()
		local d = s:GetNormalized()
		local v = pos - EyePos()
		local t = v:Dot(d)
		local p = EyePos() + t * d

		-- we are in smoke OR line of sight is intersecting smoke
		if t > -rad and t < s:Length() and p:Distance(pos) <= rad then return false end
	end
end)
