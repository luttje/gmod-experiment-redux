local ITEM = ITEM

ITEM.name = "Gnome Chomsky"
ITEM.model = "models/props_junk/gnome.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.class = "exp_gnome_chomsky"
ITEM.weaponCategory = "melee"
ITEM.description = "Hold and cherish, not much else."
ITEM.noBusiness = true
ITEM.chanceToScavenge = 0.001

if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
        local panel = tooltip:AddRowAfter("name", "quality")
        panel:SetBackgroundColor(Color(87, 85, 254))
        panel:SetText(L("rareItem"))
        panel:SizeToContents()
    end
end

function ITEM:OnEntityCreated(entity)
    local thrownDirection = self:GetData("thrown", nil)

    if (not thrownDirection) then
        return
    end

    -- First move it in the thrown direction so it doesn't collide with the player or ground
	entity:SetPos(entity:GetPos() + (thrownDirection:Forward() * 10) + (thrownDirection:Up() * 10))
	entity:Activate()

	local physObject = entity:GetPhysicsObject()

	if (IsValid(physObject)) then
		physObject:SetVelocity(thrownDirection:Forward() * math.random(500, 900))
	end

	self:SetData("thrown", nil)
end

ITEM.functions.Throw = {
	name = "Throw",
	tip = "Throw the gnome.",
	icon = "icon16/arrow_up.png",
	OnRun = function(item)
        local client = item.player

        if (item:GetData("equip")) then
            item:Unequip(client, false)
        end

        item:SetData("thrown", client:EyeAngles())

		local success, error = item:Transfer(nil, nil, nil, item.player)

        if (not success and isstring(error)) then
            item.player:NotifyLocalized(error)
            return false
        end

        item.player:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav", 75, math.random(90, 120), 1)

        client:Notify("You threw the gnome.")

		return false
    end,

    OnCanRun = function(item)
		return item:GetData("equip") == true
	end
}
