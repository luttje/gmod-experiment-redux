local ITEM = ITEM

ITEM.calibre = ".45 ACP"
ITEM.name = ITEM.calibre .. " Cartridge"
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.model = "models/experiment-redux/ammo/45acp.mdl"
ITEM.noBusiness = true
ITEM.ammoAmount = 1
ITEM.description = "A single .45 ACP cartridge"
ITEM.chanceToScavenge = Schema.RARITY_UNCOMMON

if (SERVER) then
	resource.AddFile("models/experiment-redux/ammo/45acp.mdl")
	resource.AddFile("materials/models/experiment-redux/ammo/45acp.vmt")
end
