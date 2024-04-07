ITEM.base = "base_outfit"
ITEM.name = "Armor"
ITEM.description = "A suitcase full of armored equipment."
ITEM.model = Model("models/props_c17/suitcase_passenger_physics.mdl")
ITEM.category = "Armor"
ITEM.width = 2
ITEM.height = 2
ITEM.maxArmor = 0
ITEM.noArmor = false
ITEM.removeOnDestroy = false
ITEM.hasTearGasProtection = false

-- ITEM.forceRender = true
ITEM.iconCam = {
	pos = Vector(60.86, -19.83, 66.5),
	ang = Angle(2.88, 160.64, -0.59),
	fov = 20
}

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local after = "name"

		if (self.maxArmor) then
			local panel = tooltip:AddRowAfter(after, "armor")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("Armor: " .. math.Round(self:GetData("armor", self.maxArmor), 2))
			panel:SizeToContents()

			after = "armor"
		end

		if (self.hasTearGasProtection) then
			local panel = tooltip:AddRowAfter(after, "teargas")
			panel:SetBackgroundColor(derma.GetColor("Info", tooltip))
			panel:SetText("Provides Tear Gas Protection")
			panel:SizeToContents()

			after = "teargas"
		end

		if (self.attribBoosts) then
			for attributeKey, boostAmount in pairs(self.attribBoosts) do
				local attribute = ix.attributes.list[attributeKey]
				local panel = tooltip:AddRowAfter(after, "boost" .. attributeKey)
				panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
				panel:SetText("Boosts " .. attribute.name .. " by " .. math.Round(boostAmount, 2))
				panel:SizeToContents()
			end
		end
	end

	-- Only show the armor on the client (not for dropping item entity)
	function ITEM:GetModel()
		if (self.replacement or (self.replacements and isstring(self.replacements))) then
			return self.replacement or self.replacements
		end

		if (istable(self.replacements)) then
			local model = (self.player or LocalPlayer()):GetModel()

			for _, v in ipairs(self.replacements) do
				if (model:find(v[1])) then
					return model:gsub(v[1], v[2])
				end
			end
		end

		if (self.model) then
			return self.model
		end

		error("Failed to get model for item " .. self.uniqueID)
	end
end

function ITEM:OnEquipped()
	local client = self.player
	local character = client:GetCharacter()
	local armor = self:GetData("armor", self.maxArmor)
	self:SetData("armor", armor)
	Schema.armor.SetArmor(character, self.id)

	client:EmitSound("physics/body/body_medium_impact_soft5.wav", 25, 50)
end

function ITEM:OnUnequipped()
	local client = self.player

	if (not IsValid(client)) then
		return
	end

	local character = client:GetCharacter()
	Schema.armor.RemoveArmor(character, self.id)

	client:EmitSound("physics/body/body_medium_impact_soft2.wav", 25, 50)
end

function ITEM:Repair(amount)
	self:SetData("armor", math.Clamp(self:GetData("armor", 0) + amount, 0, self.maxArmor))
end

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
		Schema.armor.SetArmor(character, self.id)
	end
end

-- The `ix_dev_icon` command doesnt help us and the code below also isn't user friendly... Find a better way
-- local function updateIconCam(itemTable, data)
-- 	itemTable = ix.item.list[itemTable.uniqueID]

-- 	local rotate = data.rotate or 0
-- 	local translate = data.translate or Vector(0, 0, 0)
-- 	local fov = data.fov or 0

-- 	PrintTable(itemTable)
-- 	itemTable.forceRender = true

-- 	itemTable.iconCam.pos = itemTable.iconCam.pos + translate
-- 	itemTable.iconCam.ang = itemTable.iconCam.ang + Angle(0, rotate, 0)
-- 	itemTable.iconCam.fov = itemTable.iconCam.fov + fov

-- 	print("Updated icon camera for", itemTable.uniqueID)
-- 	PrintTable(itemTable.iconCam)

-- 	ix.gui.inv1:RebuildItems()

-- 	return false
-- end

-- ITEM.functions.adminSpawnIconFix = {
-- 	name = "Fix Spawn Icon",
-- 	icon = "icon16/wrench.png",
-- 	isMulti = true,
-- 	multiOptions = {
-- 		{
-- 			name = "Rotate Left",
-- 			icon = "icon16/arrow_rotate_anticlockwise.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {rotate = -1}) end
-- 		},
-- 		{
-- 			name = "Rotate Left (Big)",
-- 			icon = "icon16/arrow_rotate_anticlockwise.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {rotate = -5}) end
-- 		},
-- 		{
-- 			name = "Rotate Right",
-- 			icon = "icon16/arrow_rotate_clockwise.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {rotate = 1}) end
-- 		},
-- 		{
-- 			name = "Rotate Right (Big)",
-- 			icon = "icon16/arrow_rotate_clockwise.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {rotate = 5}) end
-- 		},
-- 		{
-- 			name = "Translate Up",
-- 			icon = "icon16/arrow_up.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, 0, 1)}) end
-- 		},
-- 		{
-- 			name = "Translate Up (Big)",
-- 			icon = "icon16/arrow_up.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, 0, 5)}) end
-- 		},
-- 		{
-- 			name = "Translate Down",
-- 			icon = "icon16/arrow_down.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, 0, -1)}) end
-- 		},
-- 		{
-- 			name = "Translate Down (Big)",
-- 			icon = "icon16/arrow_down.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, 0, -5)}) end
-- 		},
-- 		{
-- 			name = "Translate Left",
-- 			icon = "icon16/arrow_left.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, -1, 0)}) end
-- 		},
-- 		{
-- 			name = "Translate Left (Big)",
-- 			icon = "icon16/arrow_left.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, -5, 0)}) end
-- 		},
-- 		{
-- 			name = "Translate Right",
-- 			icon = "icon16/arrow_right.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, 1, 0)}) end
-- 		},
-- 		{
-- 			name = "Translate Right (Big)",
-- 			icon = "icon16/arrow_right.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {translate = Vector(0, 5, 0)}) end
-- 		},
-- 		{
-- 			name = "Rotate + Translate Left (Big)",
-- 			icon = "icon16/arrow_rotate_anticlockwise.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {rotate = -5, translate = Vector(0, -5, 0)}) end
-- 		},
-- 		{
-- 			name = "Zoom In",
-- 			icon = "icon16/magnifier_zoom_in.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {fov = -1}) end
-- 		},
-- 		{
-- 			name = "Zoom In (Big)",
-- 			icon = "icon16/magnifier_zoom_in.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {fov = -10}) end
-- 		},
-- 		{
-- 			name = "Zoom Out",
-- 			icon = "icon16/magnifier_zoom_out.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {fov = 1}) end
-- 		},
-- 		{
-- 			name = "Zoom Out (Big)",
-- 			icon = "icon16/magnifier_zoom_out.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {fov = 10}) end
-- 		},
-- 		{
-- 			name = "Reset",
-- 			icon = "icon16/cancel.png",
-- 			OnClick = function(itemTable) return updateIconCam(itemTable, {rotate = 0, translate = Vector(0, 0, 0), fov = 0}) end
-- 		},
-- 		{
-- 			name = "Copy to Clipboard",
-- 			icon = "icon16/page_copy.png",
-- 			OnClick = function(itemTable)
-- 				local data = itemTable.iconCam
-- 				local text = "ITEM.iconCam = {\n"
-- 				text = text .. "\tpos = Vector(" .. data.pos.x .. ", " .. data.pos.y .. ", " .. data.pos.z .. "),\n"
-- 				text = text .. "\tang = Angle(" .. data.ang.p .. ", " .. data.ang.y .. ", " .. data.ang.r .. "),\n"
-- 				text = text .. "\tfov = " .. data.fov .. "\n}"
-- 				SetClipboardText(text)
-- 				return false
-- 			end
-- 		}
-- 	},

-- 	OnClick = function(item, data)
-- 		print("OnClick", item, data)
-- 		PrintTable(data)
-- 		return false
-- 	end,

-- 	OnRun = function(item, data)
-- 		return false
-- 	end,

-- 	OnCanRun = function(item)
-- 		return item.player:IsAdmin()
-- 	end
-- }
