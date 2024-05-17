$modelname "experiment-redux/business-sign.mdl"

$scale 1

$body "body" "business-sign.smd"
$collisionmodel	"business-sign-collision.smd" { $automass }

$surfaceprop "plastic"

$cdmaterials "models/experiment-redux/business-sign/"

$staticprop
$sequence idle "business-sign" fps 1

$texturegroup skinfamilies
{
  { "sign" }
  { "sign-on" }
  { "sign-pattern1" }
  { "sign-pattern2" }
  { "sign-pattern3" }
}