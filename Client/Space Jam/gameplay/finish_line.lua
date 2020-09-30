local physics = require "physics"
local finish = {}

function finish.new(world,y_val)    --FINISH line generation with physics collision
finishline_grp = display.newGroup()

print("FINISH LINE POS: ",y_val)
local finishline = display.newRect(-10,y_val,display.actualContentWidth+20,60)
finishline.anchorX,finishline.anchorY = 0,0.5
finishline:setFillColor(1,1,1)
finishline.myName = "finishline"

local lbl_finish = display.newText("FINISH",display.contentCenterX,y_val+25,"fonts/nasalization.ttf",80 )
  lbl_finish.anchorX, lbl_finish.anchorY = 0.5,0
  lbl_finish:setFillColor(255,255,255)


finishline_grp:insert(finishline)
finishline_grp:insert(lbl_finish)

physics.addBody( finishline, "static", {isSensor = true})


world:insert(finishline_grp)

  return finishline_grp
end

return finish
