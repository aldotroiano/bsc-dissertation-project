local physics = require "physics"
local terr = {}
local colors = {"005ce6","e60000","b82e8a","990033","cc3300"}
require "Libraries.Hex2RGB"

function terr.new(world,x_cord,y)
instance = display.newGroup()

  local left_max = x_cord
  local color = math.random(1,5)
  local r_rand, g_rand, b_rand = math.random(), math.random(),math.random()

  local l1 = display.newRoundedRect(-30,y,left_max-75,60,15)
  l1.anchorX = 0
  l1:setFillColor(hex2rgb(colors[color]))
  l1:setStrokeColor(1,1,1)


  local r1 = display.newRoundedRect(left_max+75,y,display.actualContentWidth+30,60,15)
  r1.anchorX = 0
  r1:setFillColor(hex2rgb(colors[color]))
  r1:setStrokeColor(1,1,1)


  l1.strokeWidth = 4
  r1.strokeWidth = 4

  instance:insert(l1)
  instance:insert(r1)

  physics.addBody( r1, "static")
  physics.addBody( l1, "static")
  l1.isSleepingAllowed = false
  r1.isSleepingAllowed = false
  world:insert(instance)  -- Inserting the left and right obstacle in the world

  return instance
end

return terr
