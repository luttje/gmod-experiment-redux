$modelname "experiment-redux/door_protector_basic.mdl"

$scale 1

$body "body" "door_protector_basic.smd"
$collisionmodel	"door_protector_basic_phys.smd" { $automass }

$surfaceprop "metal"

$cdmaterials "models/experiment-redux/door-protectors/"

$staticprop
$sequence idle "door_protector_basic" fps 1
