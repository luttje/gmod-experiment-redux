$modelname "experiment-redux/shopkeeper_portal_door.mdl"

$scale 2

$body "body" "shopkeeper_portal_door.smd"

$surfaceprop "metal"

$cdmaterials "models/experiment-redux/shopkeeper/"

$origin 0 0 0

$collisionmodel "shopkeeper_portal_door.smd" {
  $noselfcollisions
}

$sequence "idle" {
  "shopkeeper_portal_door.smd"
  fps 30
}

$sequence "open" {
  "shopkeeper_anims/open.smd"
  fps 30
}

$sequence "close" {
  "shopkeeper_anims/close.smd"
  fps 30
}
