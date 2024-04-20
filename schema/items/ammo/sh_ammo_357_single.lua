local ITEM = ITEM

ITEM.calibre = ".357"
ITEM.name = ITEM.calibre .. " Cartridge"
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.model = "models/experiment-redux/ammo/50ae.mdl"
ITEM.noBusiness = true
ITEM.ammoAmount = 1
ITEM.description = "A single .357 cartridge"
ITEM.chanceToScavenge = 2

if (SERVER) then
	resource.AddFile("models/experiment-redux/ammo/50ae.mdl")
    resource.AddFile("materials/models/experiment-redux/ammo/50ae.vmt")
end
