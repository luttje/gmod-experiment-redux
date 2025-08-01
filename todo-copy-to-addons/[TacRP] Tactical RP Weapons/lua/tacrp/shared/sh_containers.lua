TacRP.Containers = {
    -- {entity = entity, capacity = number, items = {}}
}

function TacRP.MakeContainer(ent, size)
    if ent.TacRP_ContainerID then return end
    ent.TacRP_ContainerID = table.insert(TacRP.Containers, {
        entity = ent,
        capacity = size or 100,
        weight = 0,
        items = {}
    })
end

function TacRP.ContainerAccessors(con_id)
    local container = TacRP.Containers[con_id]
    if !container then return {} end

    local tbl = {}

    if IsValid(container.entity) and (container.entity:GetOwner()) then
        table.insert(tbl, container.entity:GetOwner())
    end

    -- TODO: When a player is interacting with a bag entity, they should be here

    return tbl
end

function TacRP.ContainerSize(i)
    if !TacRP.Containers[i].weight then
        local weight = 0
        for k, v in pairs(TacRP.Containers[i].items) do
            weight = weight + v:GetWeight()
        end
        TacRP.Containers[i].weight = weight
    end
    return TacRP.Containers[i].weight
end

function TacRP.CanFitContainer(ent, item)
    local container = TacRP.Containers[ent.TacRP_ContainerID or -1]
    if !container then return end

    return container.weight + item:GetWeight() <= container.capacity
end

function TacRP.AddToContainer(ent, item)
    local container = TacRP.Containers[ent.TacRP_ContainerID or -1]
    if !container then return end
    if !TacRP.CanFitContainer(ent, item) then return end

    local i = table.insert(container.items, item)
    container.weight = container.weight + item:GetWeight()
    TacRP.SyncContainer(ent, i)
end

function TacRP.DropFromContainer(ent, i)
    local container = TacRP.Containers[ent.TacRP_ContainerID or -1]
    if !container then return end

    if isnumber(i) then
        local item = table.remove(container.items, i)
        container.weight = container.weight - item:GetWeight()
        TacRP.SyncContainer(ent, i)
    else
        for k, v in pairs(container.items) do
            if i == v then
                table.remove(container.items, k)
                container.weight = container.weight - i:GetWeight()
                TacRP.SyncContainer(ent, k)
                return
            end
        end
    end
end

function TacRP.SyncContainer(con_id, i, tgt)
    local con = TacRP.Containers[con_id]
    net.Start("tacrp_container")
        net.WriteUInt(con_id, 16)
        net.WriteUInt(con.capacity, 16)
        net.WriteEntity(con.entity)
        if i then
            local item = con.items[i]
            net.WriteUInt(i, 8)
            if item then
                net.WriteUInt(0, TacRP.PickupItems_Bits)
            else
                net.WriteUInt(item.ID, TacRP.PickupItems_Bits)
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
                    net.WriteUInt(0, TacRP.PickupItems_Bits)
                else
                    net.WriteUInt(item.ID, TacRP.PickupItems_Bits)
                    item:Write()
                end
            end
        end
    net.Send(tgt or TacRP.ContainerAccessors(con_id))
end

if CLIENT then
    net.Receive("tacrp_container", function()
        local con_id = net.ReadUInt(16)
        TacRP.Containers[con_id].capacity = net.ReadUInt(16)
        TacRP.Containers[con_id].entity = net.ReadEntity()
        local i = net.ReadUInt(8)

        if i == 0 then
            local item_id = net.ReadUInt(TacRP.PickupItems_Bits)
            if item_id == 0 then
                TacRP.Containers[con_id].items[i] = nil
            else
                local item = TacRP.CreateItem(item_id)
                item:Read()
                TacRP.Containers[con_id].items[i] = item
            end
        else
            for j = 1, net.ReadUInt(8) do
                local item_id = net.ReadUInt(TacRP.PickupItems_Bits)
                if item_id == 0 then
                    TacRP.Containers[con_id].items[j] = nil
                else
                    local item = TacRP.CreateItem(item_id)
                    item:Read()
                    TacRP.Containers[con_id].items[j] = item
                end
            end
        end
    end)
end