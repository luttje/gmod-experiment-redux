local PLUGIN = PLUGIN

function PLUGIN:GetMainBackgroundMaterial()
	if (self.mainBackgroundMaterial) then
		return self.mainBackgroundMaterial
	end

	self.mainBackgroundMaterial = Material("experiment-redux/background_zonda.png")
end

net.Receive("expSpawnSelectOpen", function()
	local spawns = net.ReadTable()
	local panel = vgui.Create("expSpawnSelection")
	panel:SetSpawns(spawns)
end)

net.Receive("expSpawnSelectResponse", function()
	local status = net.ReadUInt(4)

	if (status == PLUGIN.spawnResult.OK) then
		if (IsValid(ix.gui.spawnSelection)) then
			ix.gui.spawnSelection:Remove()
		end
	elseif (status == PLUGIN.spawnResult.INVALID) then
		-- ix.gui.spawnSelection:Notify("This spawn point is invalid!")
		ErrorNoHalt("[Experiment Redux] This spawn point is invalid! (TODO)\n")
	else
		ErrorNoHalt("[Experiment Redux] An unknown error occurred. (TODO)\n")
	end
end)

function PLUGIN:HUDPaint()
	local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

	local isChoosingSpawn = client:GetNetVar("expChoosingSpawn", false)

	if (not isChoosingSpawn) then
		if (self.fadeSpawnToZero and self.fadeSpawnToZero > CurTime()) then
			local alpha = 255 - math.TimeFraction(self.fadeSpawnToZero - 1, self.fadeSpawnToZero, CurTime()) * 255
			local scrW, scrH = ScrW(), ScrH()

			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, 0, scrW, scrH)
		end

		return
	end

	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, scrW, scrH)

	self.fadeSpawnToZero = CurTime() + 1
end
