local PLUGIN = PLUGIN

PLUGIN.name = "Bonemerge Hands Fix"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Will make sure hands look like the player model, by bonemerging."
PLUGIN.fakeHandsIndex = -1

if (SERVER) then
	return
end

local translateFarAway = 123456

-- Check if we should hide bones. We will hide everything that is not visible from the eyes of the player.
local function shouldHideBone(hand, boneName, parentBoneName)
	local hiddenBonesList = {
		"Head",
		"Neck",
		"Clavicle",
		"Spine",
		"Shoulder",
		"Trapezius",
		"Thigh",
		"Calf",
		"Foot",
		"Toe0"
	}

	local invalidBone = not hand:LookupBone(boneName) and not hand:LookupBone(parentBoneName)

	for _, listedBoneName in ipairs(hiddenBonesList) do
		if (string.find(boneName, listedBoneName)) then
			return true
		end
	end

	return invalidBone
end

local function getClientHands(client)
	local playerModelName = player_manager.TranslateToPlayerModelName(client:GetModel())
	local playerHands = player_manager.TranslatePlayerHands(playerModelName)

	playerHands.isDefault = playerHands.model == "models/weapons/c_arms_citizen.mdl"

	return playerHands
end

local function setupFakeHandsHidingReal(hands, viewModel, client)
	client:SetupBones()

	hands.expActiveBonemergedHandsIndex = PLUGIN.fakeHandsIndex

	local modifiedBones = {}

	if (IsValid(PLUGIN.handsModelOverlayClientsideModel)) then
		PLUGIN.handsModelOverlayClientsideModel:Remove()
	end

	for i = 0, client:GetBoneCount() - 1 do
		local boneName = client:GetBoneName(i)
		local parentBoneName = client:GetBoneName(client:GetBoneParent(i))

		if (shouldHideBone(hands, boneName, parentBoneName)) then
			modifiedBones[i] = true
		end
	end

	hands.expHandsModifiedBones = modifiedBones
	PLUGIN.handsModelOverlayClientsideModel = ClientsideModel(client:GetModel())

	function PLUGIN.handsModelOverlayClientsideModel:GetPlayerColor()
		return client:GetPlayerColor()
	end

	PLUGIN.handsModelOverlayClientsideModel:SetNoDraw(true)
	PLUGIN.handsModelOverlayClientsideModel:SetParent(viewModel)
	PLUGIN.handsModelOverlayClientsideModel:AddEffects(EF_BONEMERGE)
	PLUGIN.handsModelOverlayClientsideModel:AddEffects(EF_PARENT_ANIMATES)

	local buildBonePositions = function(fakeHands, bonesCount)
		for i = 0, bonesCount - 1 do
			local boneMatrix = fakeHands:GetBoneMatrix(i)

			if (not boneMatrix or not modifiedBones[i]) then
				continue
			end

			boneMatrix:Scale(Vector(0, 0, 0))
			boneMatrix:SetTranslation(boneMatrix:GetTranslation() - client:GetAimVector() * translateFarAway)

			fakeHands:SetBoneMatrix(i, boneMatrix)
		end
	end

	PLUGIN.handsModelOverlayClientsideModel:AddCallback("BuildBonePositions", buildBonePositions)
end

function cleanupFakeHandsRestoringReal(hands, client)
	hands.expActiveBonemergedHandsIndex = false

	hands:SetModel(getClientHands(client).model)

	if IsValid(PLUGIN.handsModelOverlayClientsideModel) then
		PLUGIN.handsModelOverlayClientsideModel:Remove()
	end
end

function PLUGIN:PreDrawPlayerHands(hands, viewModel, client, weapon)
	if (not IsValid(hands)) then
		ErrorNoHalt("Tracking whether this ever happens. If you see this tell the developer: YES IT DOES #001 - Thanks!")
		return
	end

	local overrideDefaultHands = true

	if (not IsValid(viewModel)) then
		viewModel = hands
	end

	local enabled = self.fakeHandsIndex > -1
    local initializedIndex = hands.expActiveBonemergedHandsIndex

	if (enabled and not initializedIndex) then
		setupFakeHandsHidingReal(hands, viewModel, client)
		return overrideDefaultHands
	end

	local handsAreOutdated = initializedIndex ~= self.fakeHandsIndex

	if ((not enabled and initializedIndex) or (enabled and handsAreOutdated)) then
		cleanupFakeHandsRestoringReal(hands, client)
		return
	end

	if (not enabled) then
		return
	end

	self.handsModelOverlayClientsideModel:DrawModel()

	return overrideDefaultHands
end

-- When the player model changes, we check if we get default hands. If we do, we enable the fake hands.
function PLUGIN:PlayerModelChanged(client, model, oldModel)
	if (not IsValid(client)) then
		return
	end

	local playerHands = getClientHands(client)
	local modelFitsWithDefaultHands = model:lower():StartsWith("models/humans/group0")

	if (playerHands.isDefault and not modelFitsWithDefaultHands) then
		self.fakeHandsIndex = self.fakeHandsIndex + 1
		return
	end

	-- If the hands fit the model, disable the fake hands.
	self.fakeHandsIndex = -1
end

-- Also when we load ensure we have the correct hands.
function PLUGIN:CharacterLoaded(character)
	local client = character:GetPlayer()

	if (not IsValid(client)) then
		return
	end

	self:PlayerModelChanged(client, client:GetModel(), nil)
end
