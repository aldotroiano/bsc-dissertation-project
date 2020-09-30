local composer = require('composer')
local conn_man = require "Networking.connection_manager"
local scene = composer.newScene()

go_pressed = false
function scene:create(event)
  mathmaking_view = self.view

  local modal_background = display.newRect(display.contentCenterX, display.contentCenterY,display.actualContentWidth-115,500)
  modal_background:setFillColor(0,0,0,1)
  modal_background.strokeWidth = 8
  modal_background:setStrokeColor(255,255,255)

  local lbl_username = display.newText("U  S  E  R  N  A  M  E:",display.contentCenterX,display.contentCenterY-150,"fonts/delirium.ttf",60 )
  lbl_username:setFillColor(255,255,255)

  txt_username = native.newTextField( display.contentCenterX, display.contentCenterY-75, 500, 80, onTeam )
  txt_username.inputType = "no-emoji"
  txt_username.font = native.newFont("fonts/FallingSky.otf" , 10 )
  txt_username:resizeFontToFitHeight()
  txt_username.align = "center"
  txt_username.strokeWidth = 8
  txt_username:addEventListener("userInput", onEditing)

  local bx_cancel = display.newRect(display.contentCenterX-130, display.contentCenterY+165,220,80)
  bx_cancel:setFillColor(51,0,0,0.3)
  bx_cancel.strokeWidth = 8
  bx_cancel:setStrokeColor(255,255,255)
  bx_cancel:addEventListener( "tap" , action_cancel)

  local bx_confirm = display.newRect(display.contentCenterX+130, display.contentCenterY+165,260,80)
  bx_confirm:setFillColor(0,51,0,0.3)
  bx_confirm.strokeWidth = 8
  bx_confirm:setStrokeColor(255,255,255)
  bx_confirm:addEventListener( "tap" , action_go)

  local lbl_cancel = display.newText("C A N C E L",display.contentCenterX-130,display.contentCenterY+165,"fonts/delirium.ttf",65 )
  lbl_cancel:setFillColor(255,255,255)

  lbl_confirm = display.newText("LOOK FOR PLAYERS",display.contentCenterX+130,display.contentCenterY+165,"fonts/delirium.ttf",65 )
  lbl_confirm:setFillColor(255,255,255)
    --set matchmaking screen entities
  mathmaking_view:insert(modal_background)
  mathmaking_view:insert(lbl_username)
  mathmaking_view:insert(txt_username)
  mathmaking_view:insert(bx_cancel)
  mathmaking_view:insert(bx_confirm)
  mathmaking_view:insert(lbl_cancel)
  mathmaking_view:insert(lbl_confirm)

end


function action_cancel()
composer.hideOverlay("slideRight", 200 )
multi_group.alpha = 1
end

function action_go()

if(string.len(txt_username.text) > 0 ) then
  _G.username = txt_username.text
  go_pressed = true

    conn_man.init_matchmaking()

    lbl_confirm.text = "W O R K I N G ..."
    print("MATCHMAKING WORKING")
else
  txt_username.placeholder = "Choose Username"
end
end

hide_matchmaking_initscreen = coroutine.create(function ()
composer.hideOverlay("slideLeft", 300)

coroutine.yield()

return true
end)

function scene:hide( event )
    local full_group = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object

    if ( phase == "will" ) then

      if(go_pressed == true) then
        go_pressed = false
        conn_man.init_udp(1)       --STARTING UDP CONNECTION
        parent:init_matchmaking()
      else
        parent:close_mathmaking_back()
      end
    elseif phase == "did" then
      go_pressed = false
    -- Called when the scene is now off screen
    end
end

function onEditing( event )

  if event.phase == "editing" then
    local ptxt = txt_username.text
		  ptxt = string.gsub(ptxt, "[^%w%s]", "")
		   if string.len(ptxt) > 12 then
      ptxt = string.sub(ptxt,0,12)
        end
      ptxt = string.gsub( ptxt, " ", "")
		txt_username.text = ptxt
  end

    if ( "submitted" == event.phase ) then
        native.setKeyboardFocus( nil )

    end
end
scene:addEventListener( "hide", scene )
scene:addEventListener('create' , scene)
scene:addEventListener( "destroy", scene )
return scene
