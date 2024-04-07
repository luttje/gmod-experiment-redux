local ITEM = ITEM

ITEM.name = "Flashlight"
ITEM.price = 100
ITEM.model = "models/maxofs2d/lamp_flashlight.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Reusables"
ITEM.class = "exp_flashlight"
ITEM.weaponCategory = "utility"
ITEM.description = "A flashlight to help you see in the dark."

ix.pac.RegisterPart("expFlashLightWorldModelPacData", {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Skin"] = 0,
					["UniqueID"] = "2193ed71e636ac3bc8b748181b0ad7794cfab9a59ae9c85e3a585d3675e3d81c",
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
					["Bone"] = "right hand",
					["Angles"] = Angle(12.300000190735, -9.8000001907349, -194),
					["AngleOffset"] = Angle(0, 0, 0),
					["BoneMerge"] = false,
					["Color"] = Vector(1, 1, 1),
					["Position"] = Vector(6.1923217773438, -3.3125, -1.9090000391006),
					["ClassName"] = "model2",
					["Brightness"] = 1,
					["Hide"] = false,
					["NoCulling"] = false,
					["Scale"] = Vector(0.34999999403954, 0.34999999403954, 0.34999999403954),
					["LegacyTransform"] = false,
					["EditorExpand"] = false,
					["Size"] = 1,
					["ModelModifiers"] = "",
					["Translucent"] = false,
					["BlendMode"] = "",
					["EyeTargetUID"] = "",
					["Model"] = "models/maxofs2d/lamp_flashlight.mdl",
				},
			},
		},
		["self"] = {
			["DrawOrder"] = 0,
			["UniqueID"] = "5dddc61ba1189c0ab7d1ff4307f58935ebd9612f868b195c296f47a9b876dc56",
			["Hide"] = false,
			["TargetEntityUID"] = "",
			["EditorExpand"] = true,
			["OwnerName"] = "self",
			["IsDisturbing"] = false,
			["Name"] = "my outfit",
			["Duplicate"] = false,
			["ClassName"] = "group",
		},
	},
})
