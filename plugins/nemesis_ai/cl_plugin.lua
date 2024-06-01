local PLUGIN = PLUGIN

function PLUGIN:NetworkEntityCreated(entity)
    self:HandleMonitorEntityEnteringPVS(entity)
end

-- Draw location to locker with anti-virus (if this player has a locker rot event)
function PLUGIN:HUDPaint()
    self:DrawLockerRotAntiVirusIfNeeded()
end

function PLUGIN:PaintOverItemIcon(itemIcon, itemTable, width, height)
	if (not itemTable:GetData("lockerRot")) then
		return
	end

	self:PaintLockerRotOverItemIcon(itemIcon, itemTable, width, height)
end

function PLUGIN:PostDrawTranslucentRenderables(isDrawingDepth, isDrawingSkybox)
	if (isDrawingSkybox or isDrawingDepth) then return end

	local monitorEntities = ents.FindByClass("exp_monitor")

	for _, monitor in pairs(monitorEntities) do
		if (not monitor:GetPoweredOn() or monitor:IsDormant()) then
			continue
		end

		self:SetupMonitorDrawing(monitor)
	end
end
