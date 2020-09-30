local physics = require "physics"
local boundaries = {}
--GENERATE BOUNDARIES FOR SPACESHIP ON SCREEN
function boundaries.new(world,spaceship)
bound = display.newGroup()

rx_bnd = display.newRect( display.actualContentWidth+2,display.actualContentHeight/2, 100, 1500 )
rx_bnd.anchorX, rx_bnd.anchorY = 0,0.5

lx_bnd = display.newRect( -2, display.actualContentHeight/2, 100, 1500)

lx_bnd.anchorX, lx_bnd.anchorY = 1,0.5

bound:insert(rx_bnd)
bound:insert(lx_bnd)


physics.addBody( rx_bnd, "kinematic")
physics.addBody( lx_bnd, "kinematic")

rx_bnd.isSleepingAllowed = false
lx_bnd.isSleepingAllowed = false
world:insert(bound)

  return bound
end

return boundaries
