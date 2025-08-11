local MAP = MAP

MAP.name = "City 18"
MAP.mapName = "exp_c18_v1"

MAP.waitingPosition = Vector(0, 0, 0)
MAP.waitingAngles = Angle(0, 0, 0)

if (CLIENT) then
  MAP.backgroundMaterial = Material("experiment-redux/maps/exp_c18_v1_feathered_black.png")
  MAP.backgroundOriginalWidth = 1024
  MAP.backgroundOriginalHeight = 1024
  MAP.backgroundScale = 12   -- scale used in cl_leveloverview command
  MAP.backgroundRotation = -85

  function MAP:TransformSpawnPositionToUI(position, mapWidth, mapHeight)
    -- https://developer.valvesoftware.com/wiki/Creating_a_working_mini-map_for_CS:GO
    -- Overview: scale 12.00, pos_x -6021, pos_y 6519 (orthographic)
    local screenshotPos = Vector(-6021, 6519, 0)

    -- Normalize the position
    local xNormalized = (position.x - screenshotPos.x) / (self.backgroundOriginalWidth * self.backgroundScale)
    local yNormalized = (screenshotPos.y - position.y) / (self.backgroundOriginalHeight * self.backgroundScale)

    -- Transform to UI coordinates
    local x = xNormalized * mapWidth
    local y = yNormalized * mapHeight

    return x, y
  end
else
  if (game.GetMap():StartsWith("exp_c18_v1")) then
    ix.util.AddResourceFile("materials/experiment-redux/maps/exp_c18_v1_feathered_black.png")
  end
end
