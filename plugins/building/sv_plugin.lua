local PLUGIN = PLUGIN

util.AddNetworkString("ixBuildingRequestBuildStructure")

function PLUGIN:BuildStructure(client, item, position, angles)
	local structureBaseEntity = ents.Create("exp_structure")
	structureBaseEntity:SetStructure(client, item, position, angles)
	structureBaseEntity:Spawn()
	structureBaseEntity:EmitSound("physics/wood/wood_box_impact_soft3.wav", 75, 70)

	client:Notify("You have constructed a structure blueprint, complete it by filling it with materials.")
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
		local structureBuilder = structure:GetClient()

		if (IsValid(structureBuilder) and structureBuilder == client and structure:GetUnderConstruction()) then
			client:Notify("You are already building a structure. Finish that first.")
			return
		end
	end

	item:Unequip(client, false, true)
	PLUGIN:BuildStructure(client, item, position, angles)
end)

function PLUGIN:StructureDestroyed(client, structure)
	if (not IsValid(client)) then
		return
	end

	local structureBuilder = structure:GetClient()

	if (not IsValid(structureBuilder)) then
		return
	end

	local victimData = {
		victim = structureBuilder
	}
	local buff, buffTable = Schema.buff.GetActive(client, "siege_surge", victimData)

	if (not buff) then
		Schema.buff.SetActive(client, "siege_surge", nil, victimData)
		return
	end

	buffTable:Stack(client, buff)
end
