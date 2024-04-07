for _, resourceFile in pairs(file.Find("materials/models/kevlarvest/*.*", "GAME")) do
	resource.AddFile("materials/models/kevlarvest/"..resourceFile)
end

for _, resourceFile in pairs(file.Find("models/kevlarvest/*.mdl", "GAME")) do
	resource.AddFile("models/kevlarvest/"..resourceFile)
end

local ITEM = ITEM

ITEM.name = "Kevlar Vest"
ITEM.price = 300
ITEM.model = "models/weapons/w_suitcase_passenger.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Clothing"
ITEM.outfitCategory = "vests"
ITEM.description = "A kevlar vest that provides you with extra armor."
ITEM.maxArmor = 100
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Skin"] = 0,
					["UniqueID"] = "6dd68a71db06d9b40ad9f76a72a6abded05c0a9f011f219fbe0a719c36317a3c",
					["NoLighting"] = false,
					["AimPartName"] = "",
					["IgnoreZ"] = false,
					["AimPartUID"] = "",
					["Materials"] = "",
					["Name"] = "",
					["LevelOfDetail"] = 0,
					["NoTextureFiltering"] = false,
					["PositionOffset"] = Vector(0, 0, 0),
					["IsDisturbing"] = false,
					["EyeAngles"] = false,
					["DrawOrder"] = 0,
					["TargetEntityUID"] = "",
					["Alpha"] = 1,
					["Material"] = "",
					["Invert"] = false,
					["ForceObjUrl"] = false,
					["Bone"] = "chest",
					["Angles"] = Angle(-6.814248085022, -1.092275033443e-05, 3.2244284398075e-07),
					["AngleOffset"] = Angle(0, 0, 0),
					["BoneMerge"] = false,
					["Color"] = Vector(1, 1, 1),
					["Position"] = Vector(5.541015625, 0.00146484375, -59.982360839844),
					["ClassName"] = "model2",
					["Brightness"] = 1,
					["Hide"] = false,
					["NoCulling"] = false,
					["Scale"] = Vector(0.89999997615814, 0.89999997615814, 1),
					["LegacyTransform"] = false,
					["EditorExpand"] = false,
					["Size"] = 1,
					["ModelModifiers"] = "",
					["Translucent"] = false,
					["BlendMode"] = "",
					["EyeTargetUID"] = "",
					["Model"] = "models/kevlarvest/kevlarvest.mdl",
				},
			},
		},
		["self"] = {
			["DrawOrder"] = 0,
			["UniqueID"] = "6f0eac11464a427917765885d240b797877cde83f2430bba9f2861cdf2450084",
			["Hide"] = false,
			["TargetEntityUID"] = "",
			["EditorExpand"] = true,
			["OwnerName"] = "self",
			["IsDisturbing"] = false,
			["Name"] = "kevlar",
			["Duplicate"] = false,
			["ClassName"] = "group",
		},
	},
}

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("name", "armor")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText("Armor: " .. self:GetData("armor", self.maxArmor))
		panel:SizeToContents()
	end
end

function ITEM:OnEquipped()
	local client = self.player
	local character = client:GetCharacter()

	local multiplier = Schema.perk.GetOwned(PRK_ARMORED, client) and 1.5 or 1
	local armor = self:GetData("armor", self.maxArmor * multiplier)
	self:SetData("armor", armor)

	Schema.armor.SetArmor(character, self.id)
end

function ITEM:OnUnequipped()
	local client = self.player

	if (not IsValid(client)) then
		return
	end

	local character = client:GetCharacter()
	Schema.armor.RemoveArmor(character, self.id)
end

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
		Schema.armor.SetArmor(character, self.id)
	end
end
