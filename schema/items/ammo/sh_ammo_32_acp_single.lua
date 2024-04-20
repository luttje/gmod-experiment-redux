local ITEM = ITEM

ITEM.calibre = ".32 ACP"
ITEM.name = ITEM.calibre .. " Cartridge"
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.model = "models/experiment-redux/ammo/45acp.mdl"
ITEM.noBusiness = true
ITEM.ammoAmount = 1
ITEM.description = "A single .32 ACP cartridge"
ITEM.chanceToScavenge = 2

if (SERVER) then
	resource.AddFile("models/experiment-redux/ammo/45acp.mdl")
    resource.AddFile("materials/models/experiment-redux/ammo/45acp.vmt")
end
