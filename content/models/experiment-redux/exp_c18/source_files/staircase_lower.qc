$staticprop

$modelname "experiment-redux/exp_c18/staircase_lower"
$cdmaterials "models/experiment-redux/exp_c18/textures"

$scale "1.000000"
$body "Body" "staircase_lower_ref"

$sequence idle "staircase_lower_ref"

$surfaceprop "concrete"

$collisionmodel "staircase_lower_phys" {
	$concave
	$automass
}
