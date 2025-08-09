local PLUGIN = PLUGIN

PLUGIN.tacticalOverlay = Material("effects/combine_binocoverlay")
PLUGIN.randomDisplayLines = {
	"Transmitting physical transition vector...",
	"Parsing view ports and data arrays...",
	"Updating biosignal co-ordinates...",
	"Pinging connection to network...",
	"Synchronizing locational data...",
	"Translating radio messages...",
	"Emptying outgoing pipes...",
	"Sensoring proximity...",
	"Pinging loopback...",
	"Idle connection..."
}

-- Table to store scanned inventory data
PLUGIN.scannedInventories = PLUGIN.scannedInventories or {}

net.Receive("expDisplayLine", function()
	local text = net.ReadString()
	local color = net.ReadColor()

	PLUGIN:AddDisplayLine(text, color)
end)

function PLUGIN:AddDisplayLine(text, color, ...)
	if (not IsValid(ix.gui.tacticalDisplay)) then
		return
	end

	ix.gui.tacticalDisplay:AddLine(text, color, nil, ...)
end

net.Receive("expInventorySearch", function()
	local target = net.ReadEntity()
	local itemCount = net.ReadUInt(8)
	local items = {}

	for i = 1, itemCount do
		items[#items + 1] = net.ReadString()
	end

	if (IsValid(target)) then
		PLUGIN.scannedInventories[target] = {
			items = items,
			expireTime = CurTime() + PLUGIN.inventoryExpireSeconds
		}
	end
end)


function PLUGIN:DrawInventoryInfo(target, items)
	if (not items or #items == 0) then
		return
	end

	local client = LocalPlayer()
	local targetPos = target:GetPos()

	-- Try find the head, chest bone in that order or default to GetPos()
	local lookups = { "ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine2" }

	for _, bone in ipairs(lookups) do
		local bonePos = target:GetBonePosition(target:LookupBone(bone))

		if (bonePos) then
			targetPos = bonePos
			break
		end
	end

	local screenPos = targetPos:ToScreen()

	-- Don't draw if target is not on screen
	if (not screenPos.visible) then
		return
	end

	-- Calculate distance fade
	local distance = client:GetPos():DistToSqr(target:GetPos())
	local maxDistance = 90 ^ 2
	local alpha = math.Clamp(255 - (distance / maxDistance * 255), 25, 255)

	-- Starting position (line tracing up and right from player)
	local startX = screenPos.x + 50
	local startY = screenPos.y - 100

	-- Draw background
	local itemCount = #items
	local lineHeight = 16
	local totalHeight = itemCount * lineHeight + 10
	local maxWidth = 0

	-- Calculate max width needed
	surface.SetFont("BudgetLabel")
	for _, item in ipairs(items) do
		local w, _ = surface.GetTextSize(item)
		if (w > maxWidth) then
			maxWidth = w
		end
	end
	maxWidth = maxWidth + 20

	-- Draw background box
	surface.SetDrawColor(101, 174, 124, alpha * 0.05)
	surface.DrawRect(startX - 5, startY - 5, maxWidth, totalHeight)

	-- Draw border
	surface.SetDrawColor(101, 174, 124, alpha)
	surface.DrawOutlinedRect(startX - 5, startY - 5, maxWidth, totalHeight)

	-- Draw header line from player to info box
	surface.SetDrawColor(101, 174, 124, alpha * 0.5)
	surface.DrawLine(screenPos.x, screenPos.y - 10, startX - 5, startY + totalHeight / 2)

	-- Draw items
	surface.SetFont("BudgetLabel")
	local y = startY

	for i, item in ipairs(items) do
		local color = Color(255, 255, 255, alpha)

		-- Color code certain items
		if (item:find("Currency:")) then
			color = Color(255, 215, 0, alpha) -- Gold for currency
		elseif (item:find("weapon") or item:find("Weapon")) then
			color = Color(255, 100, 100, alpha) -- Red for weapons
		elseif (item:find("armor") or item:find("Armor")) then
			color = Color(100, 100, 255, alpha) -- Blue for armor
		end

		surface.SetTextColor(color)
		surface.SetTextPos(startX, y)
		surface.DrawText("• " .. item)

		y = y + lineHeight
	end

	-- Draw scan indicator
	local scanText = "SCANNED"
	local scanW, scanH = surface.GetTextSize(scanText)
	surface.SetTextColor(101, 174, 124, alpha * 0.8)
	surface.SetTextPos(startX + maxWidth - scanW - 5, startY - scanH - 5)
	surface.DrawText(scanText)
end
