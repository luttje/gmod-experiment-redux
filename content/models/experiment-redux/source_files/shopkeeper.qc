$modelname "experiment-redux/shopkeeper.mdl"

$scale 2

$body "body" "shopkeeper.smd"

$surfaceprop "metal"

$cdmaterials "models/experiment-redux/shopkeeper/"

$collisionmodel "shopkeeper_physics.smd"
{
  $concave
  $mass 1024
}

$sequence "idle" {
  "shopkeeper_anims/idle.smd"
  loop
  fps 30
}

$sequence "inspect" {
  "shopkeeper_anims/inspect.smd"
  loop
  fps 30
}
