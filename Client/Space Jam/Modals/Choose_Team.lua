local composer = require('composer')
--local UDP_conn = require("Networking.UDP")
--local utility_TCP = require("Networking.TCP")
local conn_man = require "Networking.connection_manager"
local scene = composer.newScene()

go_pressed = false
function scene:create(event)
  choose_team_view = self.view

  local modal_background = display.newRect(display.contentCenterX, display.contentCenterY,display.actualContentWidth-115,500)
  modal_background:setFillColor(0,0,0,1)
  modal_background.strokeWidth = 8
  modal_background:setStrokeColor(255,255,255)


  local lbl_team_name = display.newText("T  e  a  m     N  a  m  e  :",display.contentCenterX,display.contentCenterY-200,"fonts/delirium.ttf",60 )
  lbl_team_name:setFillColor(255,255,255)

  txt_team = native.newTextField( display.contentCenterX, display.contentCenterY-130, 500, 80, onTeam )
  txt_team.inputType = "no-emoji"
  txt_team.font = native.newFont("fonts/FallingSky.otf" , 10 )
  txt_team:resizeFontToFitHeight()
  txt_team.align = "center"
  txt_team.strokeWidth = 8
  txt_team:addEventListener("userInput", onEditing)

  local lbl_username = display.newText("U  S  E  R  N  A  M  E:",display.contentCenterX,display.contentCenterY-30,"fonts/delirium.ttf",60 )
  lbl_team_name:setFillColor(255,255,255)

  txt_username = native.newTextField( display.contentCenterX, display.contentCenterY+40, 500, 80, onTeam )
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


  local bx_confirm = display.newRect(display.contentCenterX+130, display.contentCenterY+165,220,80)
  bx_confirm:setFillColor(0,51,0,0.3)
  bx_confirm.strokeWidth = 8
  bx_confirm:setStrokeColor(255,255,255)
  bx_confirm:addEventListener( "tap" , action_go)

  local lbl_cancel = display.newText("C A N C E L",display.contentCenterX-130,display.contentCenterY+165,"fonts/delirium.ttf",65 )
  lbl_team_name:setFillColor(255,255,255)

  lbl_confirm = display.newText("J O I N  T E A M",display.contentCenterX+130,display.contentCenterY+165,"fonts/delirium.ttf",65 )
  lbl_team_name:setFillColor(255,255,255)

  choose_team_view:insert(modal_background)
  choose_team_view:insert(lbl_team_name)
  choose_team_view:insert(lbl_username)
  choose_team_view:insert(txt_team)
  choose_team_view:insert(txt_username)
  choose_team_view:insert(bx_cancel)
  choose_team_view:insert(bx_confirm)
  choose_team_view:insert(lbl_cancel)
  choose_team_view:insert(lbl_confirm)

end


function action_cancel()
composer.hideOverlay("slideRight", 200 )
multi_group.alpha = 1
end

function action_go()

if(string.len(txt_team.text) > 0 and string.len(txt_username.text) > 0 ) then
  _G.team_name = txt_team.text
  _G.username = txt_username.text
  go_pressed = true

    conn_man.choose_team_routine()

    lbl_confirm.text = "J O I N I N G"
    print("JOINING TEAM")
else
  txt_team.placeholder = "Enter team"
  txt_username.placeholder = "Choose Username"
end
end

hide_screen_choose_team = coroutine.create(function ()
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
        conn_man.init_udp(0)       --STARTING UDP CONNECTION
        parent:init_team_game()
      else
        parent:close_team_game()
      end
    elseif phase == "did" then
      go_pressed = false
    -- Called when the scene is now off screen
    end
end

function onEditing( event )

  if event.phase == "editing" then
    local ptxt = txt_team.text
		  ptxt = string.gsub(ptxt, "[^%w%s]", "")
		   if string.len(ptxt) > 12 then
         ptxt = string.sub(ptxt,0,12)
        end
      ptxt = string.gsub(ptxt, " ", "")
		txt_team.text = ptxt

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
