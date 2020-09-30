
tablex = require("Libraries.tablex")

local max_players = 4
array_players = {}
local eoM = {}


function eoM.new()
EoM_grp = display.newGroup()
leave_pressed = false

  local modal_background = display.newRect(display.contentCenterX, display.contentCenterY,500,600)
  modal_background:setFillColor(0,0,0)
  modal_background.strokeWidth = 5
  modal_background:setStrokeColor(255,255,255)

  local lbl_title = display.newText("MATCH RANKING",display.contentCenterX,display.contentCenterY-260,"fonts/FallingSky.otf",38 )
  lbl_title.anchorX = 0.5
  lbl_title:setFillColor(255,255,255)

   bx_restart = display.newRect(display.contentCenterX, display.contentCenterY+150,200,80)
  bx_restart.anchorX = 0.5
  bx_restart:setFillColor(0,51,0,0.3)
  bx_restart.strokeWidth = 4
  bx_restart:setStrokeColor(255,255,255)


  lbl_restart = display.newText("R E S T A R T",display.contentCenterX,display.contentCenterY+150,"fonts/delirium.ttf",65 )
  lbl_restart.anchorX, lbl_restart.anchorY = 0.5,0.5
  lbl_restart:setFillColor(255,255,255)


  local bx_backtomain = display.newRect(display.contentCenterX, display.contentCenterY+240,400,80)
  bx_backtomain.anchorX = 0.5
  bx_backtomain:setFillColor(51,0,0,0.3)
  bx_backtomain.strokeWidth = 4
  bx_backtomain:setStrokeColor(255,255,255)


  lbl_backtomain = display.newText("B A C K   T O   M A I N   M E N U",display.contentCenterX,display.contentCenterY+240,"fonts/delirium.ttf",65 )
  lbl_backtomain.anchorX, lbl_backtomain.anchorY = 0.5,0.5
  lbl_backtomain:setFillColor(255,255,255)

  lbl_players = display.newText("PLAYER".."\n",display.contentCenterX-100,display.contentCenterY-200,"fonts/FallingSky.otf",34  )
  lbl_players.anchorX = 0
  lbl_players.anchorY = 0
  lbl_players:setFillColor(255,255,255)

  lbl_pos = display.newText("POS".."\n",display.contentCenterX-180,display.contentCenterY-200,"fonts/FallingSky.otf",34  )
  lbl_pos.anchorX = 0.5
  lbl_pos.anchorY = 0
  lbl_pos:setFillColor(255,255,255)

  lbl_restart_val = display.newText("RESTART".."\n",display.contentCenterX+240,display.contentCenterY-195,"fonts/FallingSky.otf",25  )
  lbl_restart_val.anchorX = 1
  lbl_restart_val.anchorY = 0
  lbl_restart_val:setFillColor(255,255,255)

  EoM_grp:insert(modal_background)
  EoM_grp:insert(lbl_title)
  EoM_grp:insert(bx_restart)
  EoM_grp:insert(lbl_restart)
  EoM_grp:insert(bx_backtomain)
  EoM_grp:insert(lbl_backtomain)
  EoM_grp:insert(lbl_players)
  EoM_grp:insert(lbl_pos)
  EoM_grp:insert(lbl_restart_val)

return EoM_grp
end

function Back_to_Main()

EoM_grp:removeSelf()    --Delete screen

end

function eoM.update_rankings(tbl)   --Update final match rankings
  if(tbl ~= nil) then
    lbl_pos.text = "POS".."\n"
    lbl_players.text = "PLAYER".."\n"
    lbl_restart_val.text = "RESTART".."\n"
  local counter = 1
  for pos = 1,4,1 do
    for i = 1,_G.Pnum,1 do
      if(tbl[tostring(i)].f == true and tbl[tostring(i)].pos == pos) then
        lbl_pos.text = lbl_pos.text..tbl[tostring(i)].pos..". ".."\n"
        lbl_players.text = lbl_players.text..tbl[tostring(i)].Usr.."\n"

        if(tbl[tostring(i)].r == true) then
          print("RESTART")
          lbl_restart_val.text = lbl_restart_val.text.."YES".."\n"
        end
      end
    end
  end

end
end

function eoM.hideRestart()
  bx_restart.alpha = 0.5
  lbl_restart.alpha = 0.5
end

return eoM
