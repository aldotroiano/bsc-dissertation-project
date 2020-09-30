local physics = require "physics"
local asteroid = {}
local map = display.newGroup()

    --ASTEROID GENERATION
function asteroid.new(world,x_cord,y)
instance = display.newGroup()


  local aster = display.newCircle(x_cord,y,30)
  aster.anchorX = 0
  aster:setFillColor(0.72,0.72,0.72)
  aster:setStrokeColor(0.55,0.55,0.54)

  aster.strokeWidth = 7

  instance:insert(aster)


  physics.addBody(aster, "dynamic", {radius = 30, friction = 30, density = 60, bounce = 100})
                                        -- TODO: fix and test bounce valUE
    aster.myName = "asteroid"


  world:insert(instance)  -- Inserting the left and right obstacle in the world

  return instance
end

return asteroid
