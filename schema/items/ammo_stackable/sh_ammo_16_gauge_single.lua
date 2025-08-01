local ITEM = ITEM

ITEM.calibre = "16 Gauge"
ITEM.name = ITEM.calibre .. " Shell"
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.model = "models/experiment-redux/ammo/12gauge.mdl"
ITEM.noBusiness = true
ITEM.ammoAmount = 1
ITEM.description = "A single 16 gauge shell"
ITEM.chanceToScavenge = 2

if (SERVER) then
	resource.AddFile("models/experiment-redux/ammo/12gauge.mdl")
    resource.AddFile("materials/models/experiment-redux/ammo/12gauge.vmt")
end
