$staticprop
$modelname "experiment-redux/exp_c18/spiral_stairs_left.mdl"
$body "Body" "spiral_stairs_left_ref"
$surfaceprop "concrete"
$contents "solid"
$illumposition 0 0 0
$cdmaterials "models/experiment-redux/exp_c18/textures"
$cbox 0 0 0 0 0 0
$bbox -160.25 -152.25 -156.25 160.25 152.25 156.25
$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0
$sequence idle "spiral_stairs_left_ref"
$collisionmodel "spiral_stairs_left_physics.smd"
{
	$concave
	$automass
}
