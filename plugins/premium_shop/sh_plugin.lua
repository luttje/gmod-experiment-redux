local PLUGIN = PLUGIN

PLUGIN.name = "Premium Shop"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds premium functionality and a premium shop system with real money purchases."

Schema.chunkedNetwork.Register("PaymentHistory", 50, 0.05)
Schema.chunkedNetwork.Register("ClaimablePackages", 30, 0.03)
Schema.chunkedNetwork.Register("AdminPayments", 50, 0.1)

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_stripe.lua")
ix.util.Include("cl_stripe.lua")

ix.lang.AddTable("english", {
	premiumShop = "Premium Shop",
})

-- Premium constants
PLUGIN.PREMIUM_CURRENCIES = {
	EUR = "€",
	-- USD = "$",
	-- GBP = "£"
}

PLUGIN.DEFAULT_CURRENCY = "EUR"

-- Premium package tracking
PLUGIN.PREMIUM_PACKAGES = {}

function PLUGIN:RegisterPremiumPackage(packageData)
	if (not packageData) then
		ix.util.SchemaError("RegisterPremiumPackage: packageData is required")
	end

	if (not packageData.key or type(packageData.key) ~= "string" or packageData.key == "") then
		ix.util.SchemaError("RegisterPremiumPackage: 'key' must be a non-empty string")
	end

	if (not packageData.name or type(packageData.name) ~= "string" or packageData.name == "") then
		ix.util.SchemaError("RegisterPremiumPackage: 'name' must be a non-empty string")
	end

	if (not packageData.image or type(packageData.image) ~= "string") then
		ix.util.SchemaError("RegisterPremiumPackage: 'image' must be a string upon registration")
	end

	if (not packageData.description or type(packageData.description) ~= "string") then
		ix.util.SchemaError("RegisterPremiumPackage: 'description' must be a string")
	end

	if (not packageData.price or type(packageData.price) ~= "number" or packageData.price <= 0) then
		ix.util.SchemaError("RegisterPremiumPackage: 'price' must be a positive number")
	end

	-- Validate currency (optional, defaults to EUR)
	if (packageData.currency and not PLUGIN.PREMIUM_CURRENCIES[packageData.currency]) then
		ix.util.SchemaError("RegisterPremiumPackage: 'currency' must be a valid currency code")
	end

	if (PLUGIN.PREMIUM_PACKAGES[packageData.key]) then
		ix.util.SchemaError("RegisterPremiumPackage: package key '" .. packageData.key .. "' is already registered")
	end

	if (SERVER) then
		local path = packageData.image

		resource.AddFile("materials/" .. path)
	end

	packageData.image = Material(packageData.image)

	packageData.currency = packageData.currency or PLUGIN.DEFAULT_CURRENCY
	packageData.category = packageData.category or "General"
	packageData.benefits = packageData.benefits or {}
	PLUGIN.PREMIUM_PACKAGES[packageData.key] = packageData
end

function Schema.GetPremiumPackage(key)
	return PLUGIN.PREMIUM_PACKAGES[key]
end

-- Theme colors
PLUGIN.THEME = {
	background = Color(45, 45, 48),
	surface = Color(60, 60, 65),
	panel = Color(55, 55, 60),
	primary = Color(0, 122, 255),
	secondary = Color(88, 166, 255),
	success = Color(40, 167, 69),
	warning = Color(255, 193, 7),
	danger = Color(220, 53, 69),
	text = Color(240, 240, 240),
	textSecondary = Color(180, 180, 180),
	border = Color(80, 80, 85),
	hover = Color(70, 70, 75),
	premium = Color(255, 215, 0),   -- Gold color for premium
	premiumAccent = Color(255, 165, 0) -- Orange accent for premium
}

--[[
	Player Meta functions
--]]

local playerMeta = FindMetaTable("Player")

function playerMeta:HasPremiumKey(key)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetCharacterNetVar("premiumPackages", {})
	return premiumPackages[key] == true
end

function playerMeta:GetPremiumPackages()
	if (not self:GetCharacter()) then
		return {}
	end

	return self:GetCharacterNetVar("premiumPackages", {})
end

--[[
	Premium Package Registrations
--]]

local ADDITIONAL_ELEMENT_SLOTS = 8
PLUGIN:RegisterPremiumPackage({
	key = "sprites_colored",
	name = "Colored Sprites Pack",
	description = "Gain access to 64 vibrant and richly detailed colored sprites for your canvas creations.",
	image = "experiment-redux/premium/sprites_colored.png",
	price = 0.99,
	currency = "EUR",
	category = "Canvas Designer",
	benefits = {
		"High-quality multicolor design assets",
		"64 Hand-crafted exclusive elements",
		ADDITIONAL_ELEMENT_SLOTS .. " Additional element slots for your canvas",
		"Expanded artistic possibilities",
	},
	additionalElementSlots = ADDITIONAL_ELEMENT_SLOTS,
})

ADDITIONAL_ELEMENT_SLOTS = 10
PLUGIN:RegisterPremiumPackage({
	key = "sprites_graffiti_don",
	name = "Graffiti Don Pack",
	description = "Unlock 75 bold graffiti tag designs featuring stylized letters, characters, and unique symbols.",
	image = "experiment-redux/premium/sprites_graffiti_don.png",
	price = 1.19,
	currency = "EUR",
	category = "Canvas Designer",
	benefits = {
		"Distinctive graffiti lettering and icons",
		"75 Rare and exclusive pieces",
		ADDITIONAL_ELEMENT_SLOTS .. " Additional element slots for your canvas",
		"More freedom for expressive layouts",
	},
	additionalElementSlots = ADDITIONAL_ELEMENT_SLOTS,
})

ADDITIONAL_ELEMENT_SLOTS = 14
PLUGIN:RegisterPremiumPackage({
	key = "sprites_graffiti_stencil",
	name = "Graffiti Stencil Pack",
	description = "Access 112 detailed stencil graffiti designs with letters, figures, and intricate cutout shapes.",
	image = "experiment-redux/premium/sprites_graffiti_stencil.png",
	price = 1.49,
	currency = "EUR",
	category = "Canvas Designer",
	benefits = {
		"Sharp and precise stencil-style elements",
		"112 Unique and exclusive graphics",
		ADDITIONAL_ELEMENT_SLOTS .. " Additional element slots for your canvas",
		"Greater variety for custom compositions"
	},
	additionalElementSlots = ADDITIONAL_ELEMENT_SLOTS
})


PLUGIN:RegisterPremiumPackage({
	key = "supporter_role",
	name = "Supporter Role",
	description = "Show your support for the server with a special supporter role!",
	image = "experiment-redux/premium/supporter_role.png",
	price = 4.99,
	currency = "EUR",
	category = "Supporter",
	benefits = {
		"Heart icon in front of OOC chat messages",
		"Our appreciation for your support!",
		"Chat without OOC chat delay"
	}
})

--[[
	Console Commands
--]]

do
	local COMMAND = {}
	COMMAND.description = "Give a premium key to a player."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.text
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, key)
		if (not PLUGIN.PREMIUM_PACKAGES[key]) then
			client:Notify("Invalid premium package key: " .. key)
			return
		end

		if (target:GivePremiumKey(key)) then
			client:Notify("Gave premium key '" .. key .. "' to " .. target:GetName())
			target:Notify("You have received the premium package: " .. PLUGIN.PREMIUM_PACKAGES[key].name)
		else
			client:Notify("Failed to give premium key to " .. target:GetName())
		end
	end

	ix.command.Add("GivePremiumKey", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Remove a premium key from a player."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.text
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, key)
		if (key == "*") then
			local premiumPackages = target:GetPremiumPackages()

			for key, _ in pairs(premiumPackages) do
				target:RemovePremiumKey(key)
			end

			client:Notify("Removed all premium keys from " .. target:GetName())
			return
		end

		if (target:RemovePremiumKey(key)) then
			client:Notify("Removed premium key '" .. key .. "' from " .. target:GetName())
			target:Notify("Your premium package '" .. key .. "' has been removed.")
		else
			client:Notify("Failed to remove premium key from " .. target:GetName())
		end
	end

	ix.command.Add("RemovePremiumKey", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "List all premium packages a player owns."
	COMMAND.arguments = {
		bit.bor(ix.type.player, ix.type.optional)
	}
	COMMAND.adminOnly = true

	function COMMAND:OnRun(client, target)
		target = target or client

		local premiumPackages = target:GetPremiumPackages()
		local packageNames = {}

		for key, _ in pairs(premiumPackages) do
			if (PLUGIN.PREMIUM_PACKAGES[key]) then
				table.insert(packageNames, PLUGIN.PREMIUM_PACKAGES[key].name .. " (" .. key .. ")")
			else
				table.insert(packageNames, "Unknown Package (" .. key .. ")")
			end
		end

		if (#packageNames > 0) then
			client:Notify(target:GetName() .. " owns: " .. table.concat(packageNames, ", "))
		else
			client:Notify(target:GetName() .. " owns no premium packages.")
		end
	end

	ix.command.Add("ListPremiumKeys", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Checks any outstanding payments for a player."
	COMMAND.arguments = {
		ix.type.player,
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, key)
		local steamid64 = target:SteamID64()

		PLUGIN:GetPlayerPayments(steamid64, function(payments)
			if (#payments == 0) then
				client:Notify(target:GetName() .. " has no payment history.")
				return
			end

			for _, payment in ipairs(payments) do
				if (payment.status == "pending") then
					PLUGIN:ForceCheckClientPayment(target, payment.session_id, payment)
				else
					client:Notify(target:GetName() .. "'s payment session " .. payment.session_id ..
						" is already processed with status: " .. payment.status)
				end
			end
		end)
	end

	ix.command.Add("PaymentsCheckPending", COMMAND)
end
