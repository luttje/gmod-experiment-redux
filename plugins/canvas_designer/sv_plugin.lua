local PLUGIN = PLUGIN

util.AddNetworkString("expCanvasDesigner")
util.AddNetworkString("expCanvasSave")
util.AddNetworkString("expCanvasCopySelector")
util.AddNetworkString("expCanvasCopy")
util.AddNetworkString("expCanvasView")
util.AddNetworkString("expSprayCanDesignSelector")
util.AddNetworkString("expSprayCanLoadDesign")
util.AddNetworkString("expSprayCanClearDesign")

ix.util.AddResourceFile("materials/models/spraycan3.vmt")
ix.util.AddResourceFile("models/sprayca2.mdl")

function PLUGIN:ValidateDesign(client, item, canvasWidth, canvasHeight, name, jsonData)
	if (not item or item:GetOwner() ~= client) then
		client:Notify("You do not own this Canvas!")
		return false
	end

	-- Validate JSON data
	local success, data = pcall(util.JSONToTable, jsonData)
	if (not success or not data) then
		client:Notify("Invalid canvas data!")
		return false
	end

	-- Validate element count and structure
	if (#data > self:GetMaximumElements(client)) then
		client:Notify("Too many elements on canvas!")
		return false
	end

	-- Validate canvas dimensions
	if (canvasWidth < self.CANVAS_MINIMUM_WIDTH or canvasWidth > self.CANVAS_MAX_WIDTH or
			canvasHeight < self.CANVAS_MINIMUM_HEIGHT or canvasHeight > self.CANVAS_MAX_HEIGHT) then
		client:Notify("Invalid canvas dimensions!")
		return false
	end

	local premiumPackages = client:GetPremiumPackages()

	-- Basic validation of each element
	for _, element in ipairs(data) do
		if (type(element) ~= "table") or
			not element.type or
			not element.x or
			not element.y or
			not element.scaleX or
			not element.scaleY or
			not element.color then
			client:Notify("Invalid canvas element data!")
			return false
		end

		-- Check if the sprite is premium and if the player has access
		local spriteType = self.SPRITES_BY_TYPE[element.type]
		local isUnlocked = not spriteType.premiumKey or premiumPackages[spriteType.premiumKey]

		if (not isUnlocked) then
			client:Notify("You do not have access to the sprite: " .. spriteType.name)
			return false
		end
	end

	return true
end

-- Handles the request to save a canvas design
net.Receive("expCanvasSave", function(length, client)
	local itemID = net.ReadUInt(32)
	local canvasWidth = net.ReadUInt(PLUGIN.CANVAS_WIDTH_BITS)
	local canvasHeight = net.ReadUInt(PLUGIN.CANVAS_HEIGHT_BITS)
	local name = net.ReadString()
	local jsonData = net.ReadString()
	local item = ix.item.instances[itemID]
	local isValid = PLUGIN:ValidateDesign(client, item, canvasWidth, canvasHeight, name, jsonData)

	if (not isValid) then
		return
	end

	item:SetData("design", {
		width = canvasWidth,
		height = canvasHeight,
		data = jsonData,
		name = name,
	})
	client:Notify("Canvas design saved!")
end)

-- Handles the request to copy the canvas design of another item in inventory
net.Receive("expCanvasCopy", function(length, client)
	local itemID = net.ReadUInt(32)
	local canvasWidth = net.ReadUInt(PLUGIN.CANVAS_WIDTH_BITS)
	local canvasHeight = net.ReadUInt(PLUGIN.CANVAS_HEIGHT_BITS)
	local name = net.ReadString()
	local jsonData = net.ReadString()
	local item = ix.item.instances[itemID]
	local isValid = PLUGIN:ValidateDesign(client, item, canvasWidth, canvasHeight, name, jsonData)

	if (not isValid) then
		return
	end

	item:SetData("design", {
		width = canvasWidth,
		height = canvasHeight,
		data = jsonData,
		name = name,
	})
	client:Notify("Canvas design copied successfully!")
end)

-- Handle loading design into spray can
net.Receive("expSprayCanLoadDesign", function(length, client)
	local itemID = net.ReadUInt(32)
	local canvasWidth = net.ReadUInt(PLUGIN.CANVAS_WIDTH_BITS)
	local canvasHeight = net.ReadUInt(PLUGIN.CANVAS_HEIGHT_BITS)
	local name = net.ReadString()
	local jsonData = net.ReadString()

	local item = ix.item.instances[itemID]
	if (not item) then
		return
	end

	local isValid = PLUGIN:ValidateDesign(client, item, canvasWidth, canvasHeight, name, jsonData)

	if (not isValid) then
		return
	end

	-- Set the design data on the spray can
	item:SetData("design", {
		width = canvasWidth,
		height = canvasHeight,
		name = name,
		data = jsonData
	})

	client:Notify("Design loaded into spray can!")
end)

-- Handle clearing design from spray can
net.Receive("expSprayCanClearDesign", function(length, client)
	local itemID = net.ReadUInt(32)

	local item = ix.item.instances[itemID]
	if (not item) then
		return
	end

	if (item:GetOwner() ~= client) then
		client:Notify("You do not own this Spray Can!")
		return
	end

	-- Clear the design data from the spray can
	item:SetData("design", nil)

	client:Notify("Spray can design cleared!")
end)
