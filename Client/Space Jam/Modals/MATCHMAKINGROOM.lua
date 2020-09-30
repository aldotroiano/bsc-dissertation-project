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

  local lbl_info = display.newText("Looking for Available Players... ",65,display.contentCenterY-260,"fonts/FallingSky.otf",40 )
  lbl_info.anchorX = 0
  lbl_info:setFillColor(255,255,255)

  local bx_leave_room = display.newRect(60, display.contentCenterY+210,220,100)
  bx_leave_room.anchorX = 0
  bx_leave_room:setFillColor(51,0,0,0.3)
  bx_leave_room.strokeWidth = 8
  bx_leave_room:setStrokeColor(255,255,255)
  bx_leave_room:addEventListener( "tap" , leave_onPressed)

  lbl_leave_room = display.newText("L E A V E",170,display.contentCenterY+210,"fonts/delirium.ttf",75 )
  lbl_leave_room.anchorX = 0.5
  lbl_leave_room:setFillColor(255,255,255)

  lbl_start = display.newText("MATCH WILL START ONCE PLAYERS ARE FOUND",display.contentCenterX,display.contentCenterY+130,"fonts/FallingSky.otf",25 )
  lbl_start.anchorX = 0.5
  lbl_start:setFillColor(255,255,255)

  lbl_players = display.newText("Available Players: - ",65,display.contentCenterY-200,"fonts/FallingSky.otf",38  )
  lbl_players.anchorX = 0
  lbl_players.anchorY = 0
  lbl_players:setFillColor(255,255,255)

  Team_room_view:insert(modal_background)
  Team_room_view:insert(lbl_info)
  Team_room_view:insert(bx_leave_room)
  Team_room_view:insert(lbl_leave_room)
  Team_room_view:insert(lbl_start)
  Team_room_view:insert(lbl_players)


end

function leave_onPressed ()   --leave closes connection tcp and udp
leave_pressed = true
composer.hideOverlay("slideRight", 200)
lbl_leave_room.text = "L E A V I N G"
end



function matchmaking_room(json_players)     --matchmaking room update
  lbl_players.text = ""
  if(json_players ~= nil) then      --show available players to play with from server
    lbl_players.text = "Available Players: "..json_players.NPlayers.."\n".."Creating match..."
  end
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then


	elseif phase == "did" then
		-- Called when the scene is now on screen
		--

		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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
          parent:back_from_room()   --closes connections
        end
        if(start_pressed) then
          start_pressed = false
          parent:starting_game()    --start match if HOST
        end

      -- Called when the scene is now off screen
      end
end


scene:addEventListener( "hide", scene )
scene:addEventListener('create' , scene)
scene:addEventListener( "destroy", scene )
scene:addEventListener( "show", scene )
return scene
