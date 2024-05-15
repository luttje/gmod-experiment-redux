$staticprop

$modelname "experiment-redux/exp_c18/spiral_stairs_right.mdl"
$cdmaterials "models/experiment-redux/exp_c18/textures"

$scale "1.000000"
$body "Body" "spiral_stairs_right_ref"

$sequence idle "spiral_stairs_right_ref"

$surfaceprop "concrete"

$collisionmodel "spiral_stairs_right_physics" {
	$mass 95521.41
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave
	$maxconvexpieces 42
}
