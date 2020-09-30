local sidebar = {}
local colors = {"005ce6","e60000","b82e8a","990033","cc3300"}
require "Libraries.Hex2RGB"
sdbr_grp = display.newGroup()
local players = {}
totaly_global = 0

--    SIDEBAR GENERATION
function sidebar.createcontainer()

  local container = display.newRoundedRect(display.actualContentWidth+15,150,65,750,10)
  container.anchorX,container.anchorY = 1,0
  container:setFillColor(0,0,0)
  container:setStrokeColor(0.60,0.60,0.60)
  container.strokeWidth = 6

  sdbr_grp:insert(container)


end

function sidebar.createline()

  local line = display.newRect(display.actualContentWidth-22,525,5,650)
  line.anchorX,line.anchorY = 0.5,0.5
  line:setFillColor(1,1,1)
  line.alpha = 0.8

  local startline = display.newRect(line.x,line.y+325,22,4)
  startline.anchorX,line.anchorY = 0.5,0.5
  startline:setFillColor(0.8,0.8,0.8)


  local finishline = display.newRect(line.x,line.y-325,22,4)
  finishline.anchorX,line.anchorY = 0.5,0.5
  finishline:setFillColor(0.8,0.8,0.8)


  local lbl_start = display.newText("START",line.x,line.y+340,"fonts/FallingSky.otf",15 )
  lbl_start.anchorX, lbl_start.anchorY = 0.5,0.5
  lbl_start:setFillColor(255,255,255)

  local lbl_finish = display.newText("FINISH",line.x,line.y-340,"fonts/FallingSky.otf",15 )
  lbl_finish.anchorX, lbl_finish.anchorY = 0.5,0.5
  lbl_finish:setFillColor(255,255,255)

  sdbr_grp:insert(line)
  sdbr_grp:insert(startline)
  sdbr_grp:insert(finishline)
  sdbr_grp:insert(lbl_start)
  sdbr_grp:insert(lbl_finish)


end


function sidebar.spawnMain(index,spaceshipy)

  main = display.newRoundedRect(display.actualContentWidth-12,proportions(spaceshipy),60,10,13)

  main:setFillColor(1,1,1)
  players[index] = main
  sdbr_grp:insert(main)
end

function sidebar.spawnOpponent(index,opponenty)
  opponent = display.newRoundedRect(display.actualContentWidth-8,proportions(opponenty),50,9,13)
  opponent:setFillColor(hex2rgb(colors[index]))
  opponent.alpha = 0.7
  players[index] = opponent
  sdbr_grp:insert(opponent)
end

function sidebar.setAlpha()
sdbr_grp.alpha = 0.5
end

function sidebar.setMain(i,spaceshipy)
players[i].y = proportions(spaceshipy)
end

function sidebar.setOpponent(i,opponenty)
players[i].y = proportions(opponenty)
end

function proportions(spacey)
  if _G.totaly ~= nil then
    local prop = 640/(_G.totaly)
    if spacey < 0 then
      return (850+(-prop*(-spacey)))
    else
      return 850
    end
  else
    return 850
  end
end

function sidebar.removeAll()
for i = 1, #sdbr_grp, 1 do
sdbr_grp[i]:removeSelf()

end


end


return sidebar
