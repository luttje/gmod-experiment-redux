local ITEM = ITEM

ITEM.base = "base_weapons"
ITEM.name = "CW2.0 Weapon"
ITEM.description = "A weapon that can be enhanced with attachments."

function ITEM:OnEquipWeapon(client, weapon)
    local attachments = self:GetData("attachments", {})

	if (not IsValid(weapon)) then
		return
	end

    for attachmentCategoryId, attachmentName in pairs(attachments) do
        weapon:Attach(attachmentCategoryId, attachmentName, true, true)
    end

    weapon:NetworkWeapon()
    TacRP:PlayerSendAttInv(client)
end

if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
        local attachments = self:GetData("attachments", {})
        local swep = weapons.Get(self.class)
        local ammo = swep.Primary.Ammo

		if (weapons.IsBasedOn(self.class, "tacrp_base")) then
			ammo = swep.Ammo -- For TacRP
		end

		ammo = Schema.ammo.ConvertToCalibreName(ammo)

        local panel = tooltip:AddRowAfter("name", "ammo")
        panel:SetBackgroundColor(derma.GetColor("Info", tooltip))
        panel:SetText("Ammo: " .. ammo)
		panel:SizeToContents()

        for attachmentCategoryId, attachmentName in pairs(attachments) do
            local attachment = TacRP.GetAttTable(attachmentName)

            local panel = tooltip:AddRowAfter("ammo", "attachments" .. attachmentCategoryId)
            panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
            panel:SetText(attachment.PrintName)
            panel:SizeToContents()
        end

		return tooltip
	end
end
