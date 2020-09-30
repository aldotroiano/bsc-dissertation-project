local composer = require('composer')
tablex = require("Libraries.tablex")
local scene = composer.newScene()
local leave_pressed = false
local start_pressed = false
local max_players = 4
array_players = {}

function scene:create(event)
Team_room_view = self.view
leave_pressed = false

  local modal_background = display.newRect(display.contentCenterX, display.contentCenterY,display.actualContentWidth-50,600)
  modal_background:setFillColor(0,0,0,1)
  modal_background.strokeWidth = 8
  modal_background:setStrokeColor(255,255,255)

  local lbl_team_name = display.newText("LOBBY: ".._G.team_name,65,display.contentCenterY-260,"fonts/FallingSky.otf",42 )
  lbl_team_name.anchorX = 0
  lbl_team_name:setFillColor(255,255,255)

  local bx_leave_room = display.newRect(60, display.contentCenterY+210,220,100)
  bx_leave_room.anchorX = 0
  bx_leave_room:setFillColor(51,0,0,0.3)
  bx_leave_room.strokeWidth = 8
  bx_leave_room:setStrokeColor(255,255,255)
  bx_leave_room:addEventListener( "tap" , leave_onPressed)

  bx_start = display.newRect(display.actualContentWidth-60, display.contentCenterY+210,220,100)
  bx_start.anchorX = 1
  bx_start:setFillColor(0,51,0,0.3)
  bx_start.strokeWidth = 8
  bx_start:setStrokeColor(255,255,255)
  bx_start:addEventListener( "tap" , start_onPressed)

  lbl_leave_room = display.newText("L E A V E",170,display.contentCenterY+210,"fonts/delirium.ttf",75 )
  lbl_leave_room.anchorX = 0.5
  lbl_leave_room:setFillColor(255,255,255)

  lbl_start = display.newText("S T A R T",display.actualContentWidth-165,display.contentCenterY+210,"fonts/delirium.ttf",75 )
  lbl_start.anchorX = 0.5
  lbl_start:setFillColor(255,255,255)

  lbl_players = display.newText("Loading Team...",65,display.contentCenterY-200,"fonts/FallingSky.otf",42  )
  lbl_players.anchorX = 0
  lbl_players.anchorY = 0
  lbl_players:setFillColor(255,255,255)

  lbl_hosts = display.newText("",display.actualContentWidth-100,display.contentCenterY-195,"fonts/FallingSky.otf",36  )
  lbl_hosts.anchorX = 0.5
  lbl_hosts.anchorY = 0
  lbl_hosts:setFillColor(255,255,255)

  Team_room_view:insert(modal_background)
  Team_room_view:insert(lbl_team_name)
  Team_room_view:insert(bx_leave_room)
  Team_room_view:insert(bx_start)
  Team_room_view:insert(lbl_leave_room)
  Team_room_view:insert(lbl_start)
  Team_room_view:insert(lbl_players)
  Team_room_view:insert(lbl_hosts)

end

function leave_onPressed ()   --leave and close connections
leave_pressed = true
composer.hideOverlay("slideRight", 200)
lbl_leave_room.text = "L E A V I N G"
end


function start_onPressed()    --start match if HOST
print("START")
if _G.is_host == 1 then
  start_pressed = true
  composer.hideOverlay("slideLeft", 200)
  lbl_start.text = "S T A R T I N G"
end
end



function update_room(json_players)    --TEAM ROOM (custom algorithm) to read host and team players from Server updates
  lbl_players.text = ""
  lbl_hosts.text = ""
  if(json_players ~= nil) then
    local counter = 0
    while(counter < tablex.size(json_players)/2) do
      if(json_players["NAME"..counter] ~= nil) then
        lbl_players.text = lbl_players.text..(counter+1)..".  "..json_players["NAME"..counter].."\n"
      end
      if(json_players["HOST"..counter] ~= nil) then
        if(json_players["HOST"..counter] == 1) then
          lbl_hosts.text = lbl_hosts.text.."HOST".."\n"
          if(json_players["NAME"..counter] == _G.username) then
            _G.is_host = 1
            lbl_start.alpha , bx_start.alpha = 1,1
          else
            _G.is_host = 0
            lbl_start.alpha , bx_start.alpha = 0.4,0.4
          end
        else
          lbl_hosts.text = lbl_hosts.text.."---".."\n"
        end
        counter = counter + 1
      end
    end
  end
end


function scene:hide( event )
    local full_group = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object

    if ( phase == "will" ) then

      elseif phase == "did" then
        if(leave_pressed) then
          leave_pressed = false
          parent:back_from_room()   --start
        end
        if(start_pressed) then
          start_pressed = false
          parent:starting_game()    --start match
        end
      end
end


scene:addEventListener( "hide", scene )
scene:addEventListener('create' , scene)
scene:addEventListener( "destroy", scene )
scene:addEventListener( "show", scene )
return scene
