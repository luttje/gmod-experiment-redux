local PLUGIN = PLUGIN

util.AddNetworkString("ixBuildingRequestBuildStructure")

function PLUGIN:BuildStructure(client, item, position, angles)
	local structureBaseEntity = ents.Create("exp_structure")
	structureBaseEntity:SetStructure(client, item, position, angles)
	structureBaseEntity:Spawn()

	return structureBaseEntity
end

net.Receive("ixBuildingRequestBuildStructure", function(_, client)
	local position = net.ReadVector()
	local angles = net.ReadAngle()

	if (Schema.util.Throttle("BuildStructure", 2, client)) then
		return
	end

	local weapon = client:GetActiveWeapon()

	if (not IsValid(weapon) or weapon:GetClass() ~= "exp_structure_builder") then
		client:Notify("You must have the blueprint equipped.")
		return
	end

	local item = weapon.ixItem

	if (not item) then
		client:Notify("You do not have the required blueprint.")
		return
	end

	local structures = ents.FindByClass("exp_structure")

	for _, structure in ipairs(structures) do
		local structureBuilder = structure:GetBuilder()

		if (IsValid(structureBuilder) and structureBuilder == client and structure:GetUnderConstruction()) then
			client:Notify("You are already building a structure. Finish that first.")
			return
		end
	end

    local isPlacementValid, otherStructure = PLUGIN:GetPlacementValid(client, position, angles)

	if (not isPlacementValid) then
		client:Notify("You cannot build this far off the ground.")
		return
	end

    local structure = PLUGIN:BuildStructure(client, item, position, angles)
	local otherStructureGroundLevel = IsValid(otherStructure) and otherStructure:GetGroundLevel() or 0
	structure:SetGroundLevel(otherStructureGroundLevel + 1)

	item:Unequip(client, false, true)

	structure:EmitSound("physics/wood/wood_box_impact_soft3.wav", 75, 70)

	client:Notify("You have constructed a structure blueprint, complete it by filling it with materials.")
end)
