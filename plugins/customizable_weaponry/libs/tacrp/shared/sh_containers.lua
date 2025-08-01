local PLUGIN = PLUGIN
PLUGIN.Containers = {
	-- {entity = entity, capacity = number, items = {}}
}

function PLUGIN.MakeContainer(ent, size)
	if ent.exp_tacrp_ContainerID then return end
	ent.exp_tacrp_ContainerID = table.insert(PLUGIN.Containers, {
		entity = ent,
		capacity = size or 100,
		weight = 0,
		items = {}
	})
end

function PLUGIN.ContainerAccessors(con_id)
	local container = PLUGIN.Containers[con_id]
	if ! container then return {} end

	local tbl = {}

	if IsValid(container.entity) and (container.entity:GetOwner()) then
		table.insert(tbl, container.entity:GetOwner())
	end

	-- TODO: When a player is interacting with a bag entity, they should be here

	return tbl
end

function PLUGIN.ContainerSize(i)
	if ! PLUGIN.Containers[i].weight then
		local weight = 0
		for k, v in pairs(PLUGIN.Containers[i].items) do
			weight = weight + v:GetWeight()
		end
		PLUGIN.Containers[i].weight = weight
	end
	return PLUGIN.Containers[i].weight
end

function PLUGIN.CanFitContainer(ent, item)
	local container = PLUGIN.Containers[ent.exp_tacrp_ContainerID or -1]
	if ! container then return end

	return container.weight + item:GetWeight() <= container.capacity
end

function PLUGIN.AddToContainer(ent, item)
	local container = PLUGIN.Containers[ent.exp_tacrp_ContainerID or -1]
	if ! container then return end
	if ! PLUGIN.CanFitContainer(ent, item) then return end

	local i = table.insert(container.items, item)
	container.weight = container.weight + item:GetWeight()
	PLUGIN.SyncContainer(ent, i)
end

function PLUGIN.DropFromContainer(ent, i)
	local container = PLUGIN.Containers[ent.exp_tacrp_ContainerID or -1]
	if ! container then return end

	if isnumber(i) then
		local item = table.remove(container.items, i)
		container.weight = container.weight - item:GetWeight()
		PLUGIN.SyncContainer(ent, i)
	else
		for k, v in pairs(container.items) do
			if i == v then
				table.remove(container.items, k)
				container.weight = container.weight - i:GetWeight()
				PLUGIN.SyncContainer(ent, k)
				return
			end
		end
	end
end

function PLUGIN.SyncContainer(con_id, i, tgt)
	local con = PLUGIN.Containers[con_id]
	net.Start("tacrp_container")
	net.WriteUInt(con_id, 16)
	net.WriteUInt(con.capacity, 16)
	net.WriteEntity(con.entity)
	if i then
		local item = con.items[i]
		net.WriteUInt(i, 8)
		if item then
			net.WriteUInt(0, PLUGIN.PickupItems_Bits)
		else
			net.WriteUInt(item.ID, PLUGIN.PickupItems_Bits)
			item:Write()
		end
	else
		local count = table.Count(con.items)
		net.WriteUInt(0, 8)
		net.WriteUInt(count, 8)
		for j = 1, count do
			local item = con.items[j]
			net.WriteUInt(i, 8)
			if item then
				net.WriteUInt(0, PLUGIN.PickupItems_Bits)
			else
				net.WriteUInt(item.ID, PLUGIN.PickupItems_Bits)
				item:Write()
			end
		end
	end
	net.Send(tgt or PLUGIN.ContainerAccessors(con_id))
end

if CLIENT then
	net.Receive("tacrp_container", function()
		local con_id = net.ReadUInt(16)
		PLUGIN.Containers[con_id].capacity = net.ReadUInt(16)
		PLUGIN.Containers[con_id].entity = net.ReadEntity()
		local i = net.ReadUInt(8)

		if i == 0 then
			local item_id = net.ReadUInt(PLUGIN.PickupItems_Bits)
			if item_id == 0 then
				PLUGIN.Containers[con_id].items[i] = nil
			else
				local item = PLUGIN.CreateItem(item_id)
				item:Read()
				PLUGIN.Containers[con_id].items[i] = item
			end
		else
			for j = 1, net.ReadUInt(8) do
				local item_id = net.ReadUInt(PLUGIN.PickupItems_Bits)
				if item_id == 0 then
					PLUGIN.Containers[con_id].items[j] = nil
				else
					local item = PLUGIN.CreateItem(item_id)
					item:Read()
					PLUGIN.Containers[con_id].items[j] = item
				end
			end
		end
	end)
end
