$modelname "experiment-redux/exp_c18/subway_car.mdl"
$staticprop
$body "Body" "subway_car_ref"
$surfaceprop "metal"
$contents "solid"
$illumposition 0 0.005 0
$cdmaterials "models/experiment-redux/exp_c18/textures"
$cbox 0 0 0 0 0 0
$bbox -140.612 -322.25 -93.5 140.603 322.25 94.25
$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0
$sequence idle "subway_car_ref"
$collisionmodel "subway_car_physics.smd"
{
	$concave
	$automass
}
