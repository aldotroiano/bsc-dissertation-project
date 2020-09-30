
local composer = require( "composer" )
local scene = composer.newScene()
local physics = require "physics"
local opponents = require "gameplay.opponents"
local boundaries = require "gameplay.boundaries"
local finish = require "gameplay.finish_line"
local sidebar = require "gameplay.sidebar"
local terrains = require "gameplay.terrain_generator"
local asteroids = require "gameplay.asteroid_generator"
local eoM = require "gameplay.EOMatch"
local tcp = require "Networking.TCP"
local perspective = require("Libraries.perspective")
require "ssk2.loadSSK"
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local world, spaceship		--Initialization world and spaceship entities
local terrain, asteroid = {},{}			--Initiatlization terrain and asteroid arrays
local players = {}									--Init player array
local modalEnd, sidebar_grp = {},{}
local pos_endings = {"st","nd","rd","th"}			--Endings for position on game screen
local terrain_c, asteroid_c = 1,1
local num_players = 4				--Max players
local start = false					--Game has started
_G.finished = false					--Game has finished (global)

camera = perspective.createView()			--Creating view camera (perspective)
_G.ssk.init()													--Init of physics thrust motor for spaceships

function scene:create( event )
	game_group = self.view				--Game group containing game
	physics.start()								--init physics start
	physics.pause()								--init physics pause

	physics.setGravity( 0, 0 )		--nogravity

	world = display.newGroup()		--World group containing entities (players, obstacles)

	background = display.newRect( display.screenOriginX, display.screenOriginY-10, screenW, screenH+10 )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor(0,0,0)
	background.strokeWidth = 13
	background:setStrokeColor(0.60,0.60,0.60)

--Option bar at top containig boost and health
	local options_bar = display.newRect(display.screenOriginX+6,display.screenOriginY,screenW-12,100)
	options_bar.anchorX = 0
	options_bar.anchorY = 0
	options_bar.alpha = 0.8
	options_bar:toFront()
	options_bar:setFillColor(0.3,0.3,0.3)

--Health label in option bar
	health_title_lbl = display.newText("HEALTH:", (display.actualContentWidth/6),display.screenOriginY +10 )
	health_title_lbl.anchorX, health_title_lbl.anchorY = 0.5,0
	health_title_lbl.size = 22

--Health indicator in option bar
	health_lbl = display.newText("100%", (display.actualContentWidth/6),display.screenOriginY +45 )
	health_lbl.anchorX, health_lbl.anchorY = 0.5,0
	health_lbl.size = 35

--Boost label in option bar
	boost_title_lbl = display.newText("BOOST:", (display.actualContentWidth/6)*5,display.screenOriginY +10 )
	boost_title_lbl.anchorX, boost_title_lbl.anchorY = 0.5,0
	boost_title_lbl.size = 22

--Boost indicator in option bar
	boost_lbl = display.newText("0%", (display.actualContentWidth/6)*5,display.screenOriginY +45 )
	boost_lbl.anchorX, boost_lbl.anchorY = 0.5,0
	boost_lbl.size = 35

--Position indicator in option bar
	Position_lbl = display.newText("-", (display.actualContentWidth/6)*3,display.screenOriginY +45 )
	Position_lbl.anchorX, Position_lbl.anchorY = 0.5,0.5
	Position_lbl.size = 80

--Status message during match initialization
	status_message = display.newText( "Connecting",display.contentCenterX,105,"fonts/FallingSky.otf",30 )

--RULES
	rules1 = display.newText("AVOID HITTING ASTEROIDS TO NOT LOSE HEALTH",display.contentCenterX,180,"fonts/FallingSky.otf",22)
	rules2 = display.newText("CATCH SOME BOOSTS TO INCREASE YOUR SPEED",display.contentCenterX,220,"fonts/FallingSky.otf",22)
	rules3 = display.newText("BUMP INTO YOUR OPPONENTS TO DERAIL THEM",display.contentCenterX,260,"fonts/FallingSky.otf",21.5)
	rules4 = display.newText("FIRST ONE TO CROSS THE FINISH LINE WINS",display.contentCenterX,300,"fonts/FallingSky.otf",22)

--Countdown to game start
	countdown_lbl = display.newText( " ",display.contentCenterX,180,"fonts/FallingSky.otf",100 )

--Initializing gif of fire under spaceships
	local sheet_firespace = graphics.newImageSheet( "Assets/spaceship.png", {width=85, height=149, numFrames = 8}  )
	spaceship = display.newSprite( sheet_firespace, {start=1, count=8, time=400, loopCount=0,loopDirection="forward"} )
	spaceship.y = 600
	spaceship.myName = "spaceship"
	spaceship.x = display.contentCenterX
	spaceship.speed = 450		--deafult speed of spaceship

	local outline = {25,-92,  35,50, -30,50, -25,-92 }		--outline of spaceship
	spaceship.anchorY, spaceship.anchorX = 0.5,0.5
	spaceship:play()		--playing spaceship animation
	spaceship.collision = onLocalCollision

	spaceship:addEventListener( "collision" )

	physics.addBody( spaceship, "dynamic", {shape = outline, density=45,friction=0,bounce=0})

	spaceship.isBullet = true			--runtime detection collision

	spawnBoundaries()			--Spawn boundaries to avoid spaceships going out of screen
	spawnSidebar()				--Spawn sidebar for player status
-- DEBUG :modalEnd = eoM.new()

	-- DEBUG : asteroids.new(world,200,300)
	--DEBUG : spawnPlayers(1,200,600,"aldo")
	-- DEBUG : terrains.new(world,300, 300)

	game_group:insert(background)
	game_group:insert(options_bar)
	game_group:insert(health_lbl)

	game_group:insert(spaceship)
	game_group:insert(health_title_lbl)
	game_group:insert(boost_title_lbl)
	game_group:insert(boost_lbl)
	game_group:insert(Position_lbl)

--DEBUG: composer.showOverlay("Modals.EOMatch", {isModal = true, effect = "fromRight", time = 200})

	camera:add(spaceship,1)		--Assign camera to spaceship
	camera.damping = 10				--camera damping for smooth movement
	ship_movement()					--main spaceship movement function timer start
	camera:setFocus(spaceship)		--set focus of camera on spaceship
	camera:track()							--track spaceship start
	-- DEBUG: physics.setDrawMode( "hybrid" )   -- Shows collision engine outlines only
	physics.start()			--start physics

end


function updateTimer_start(rem_time)		--start timer

	tmr_countdown = timer.performWithDelay( 1000, function()

		rem_time = rem_time - 1
			--COUNTDOWN TIMER FROM TIMESTAMP
		if(rem_time ~= 0) then

			if(rem_time < 4) then
				status_message.alpha = 0
				rules1.alpha, rules2.alpha, rules3.alpha, rules4.alpha = 0,0,0,0
				countdown_lbl.text = rem_time
			end
		else
			countdown_lbl.size = 110
			countdown_lbl.text = "GO!"
			timer.cancel( tmr_countdown)
			timer.performWithDelay( 700, function()
				transition.fadeOut( countdown_lbl, { time=200 } )
				start = true

			end,1)
		end
	end,0)
end

function set_status_message(message)
	status_message.text = message			--Status message text update
end

function spawnBoundaries()
	bond = boundaries.new(world,spaceship)			--Initialize boundaries on screen
	bond:toBack()		--bring back for visualization purposes

end

function spawnEnd(y_val)			--Spawn finish line
	finishline = finish.new(world,-y_val)

	camera:add(finishline,7)		--add finish line to camera

end

function spawnObstacle(x,y)			--spawn obstacle
	print("Spawning terrain block")
	terrain[#terrain+1] = terrains.new(world,x, display.contentCenterY - y)			--Add obstacle to terrain array
	terrain[#terrain]:toBack()
	terrain_c = terrain_c + 1		--terrain counter increment
	camera:add(terrain[#terrain],3)			--add obstacle to camera
end

function spawnAsteroid(x,y)		--spawn asteroid
	print("Spawning Asteroids")
	asteroid[#asteroid+1] = asteroids.new(world,x, display.contentCenterY - y)			--add asteroid to asteroid array
	asteroid[#asteroid]:toBack()
	asteroid_c = asteroid_c + 1			--asteroid counter increment
	camera:add(asteroid[#asteroid],5)			--add asteroid to camera
end

function spawnSidebar()		--Spawn sidebar on initialization
	sidebar.createcontainer()			--container creation
	sidebar_grp = sidebar.createline()			--line creation
end

function spawnSidebarMain(i,spaceship_y)			--spawn main character on sidebar

	sidebar.spawnMain(i,spaceship_y)			--spawn main character

end

function spawnSidebarOpponent(i,opponent_y)			--spawn sidebar opponent
	sidebar.spawnOpponent(i,opponent_y)			--spawn sidebar opponent using index
end

function onLocalCollision( self, event )			--oncollision event

	if self.myName == "spaceship" and event.other.myName == "asteroid" then
		_G.health = _G.health - 1
		health_lbl.text = _G.health.."%"
	end
	if self.myName == "spaceship" and event.other.myName == "opponent" then
		_G.health = _G.health - 1
		health_lbl.text = _G.health.."%"
	end


	if ( event.phase == "began" ) then

		print( "collision began wit")

	elseif ( event.phase == "ended" ) then

		print("collision ended")

	end
end


function spawnPlayerMain(x,y)			--Main player initialization x and y
	print("Spawning Main Player")
	_G.x = x
	_G.y = y
	_G.health = 100;
	print("x,y of MAIN : ", x, " ", y)
	spaceship.x, spaceship.y = x, y

end

function spawnPlayers(i,x,y,name)			--initialize opponents on screen
	print("Spawning opponents at", x , y)
	players[i] = opponents.new(world,i,x,y,name)			--add to player array from server gen data
	players[i]:toFront()			--bring to front
	camera:add(players[i],4)	--Add to camera

end


function setPlayers(tbl)			--set position of players from server data

	for i = 1,_G.Pnum,1 do
		if(i ~= _G.Pindex) then		--LINEAR INTERPOLATION OPERATION
			players[i][1].x = tbl[tostring(i)].x
			players[i][1].y = tbl[tostring(i)].y
			players[i][1].rotation = tbl[tostring(i)].rot
			sidebar.setOpponent(i,tbl[tostring(i)].y)
		elseif((i == _G.Pindex)) then
			if(tbl[tostring(i)].f == true and _G.finished == false) then
				modalEnd = eoM.new()
				modalEnd[3]:addEventListener("tap",restart_game)			--Modal restart onclick
				_G.finished = true
				end
				sidebar.setMain(i,spaceship.y)
				Position_lbl.text = tbl[tostring(i)].pos..pos_endings[tbl[tostring(i)].pos]
		end

	end
	if(_G.finished == true and modalEnd ~= nil) then
		eoM.update_rankings(tbl)		--Rankings
	end

end


function ship_movement()

	tmr_move = timer.performWithDelay( 2, function()
		if start and _G.finished == false then

			--spaceship:setLinearVelocity( 0, -50,spaceship.x,spaceship.y)

			--spaceship:applyForce(spaceship.speed*xComp,spaceship.speed*yComp,spaceship.x,spaceship.y)

			ssk.actions.move.forward( spaceship, {rate = spaceship.speed} )
			for i = 1,_G.Pnum,1 do
				if(i ~= _G.Pindex) then
					ssk.actions.move.forward( players[i][1], {rate = spaceship.speed} )		--Move all spaceships by set speed
				end
			end
			bond[1].y = spaceship.y		--move boundaries
			bond[2].y = spaceship.y

			--ssk.actions.movep.forward( spaceship, {rate = spaceship.speed} )
			--ssk.actions.movep.impulseForward( spaceship, {rate = spaceship.speed} )
			--spaceship:applyLinearImpulse(spaceship.speed*xComp, spaceship.speed*yComp, spaceship.x, spaceship.y)
			--spaceship:applyForce((math.cos(math.rad(spaceship.rotation)) * spaceship.speed),(-1 * math.sin(math.rad(spaceship.rotation)) * (spaceship.speed)))
			--spaceship:translate(0,-spaceship.speed)
			--	health_title_lbl.text = math.floor(spaceship.y)
			_G.y = spaceship.y
			_G.x = spaceship.x
			print(_G.x)
			print(_G.y)
			_G.rotation = math.floor(spaceship.rotation)
		end

	end,0)
end

local function Moveship(event)
	if(event.x > 60 and event.x < display.actualContentWidth - 60) then

		--local vecX, vecY = angle2VecDeg( spaceship.rotation )

		--spaceship.angularVelocity = 0
		--spaceship:applyForce ( vecX, vecY, spaceship.x, spaceship.y-30 )
		--spaceship:applyAngularImpulse( 10 )
		--spaceship:applyTorque(1)
		--spaceship:applyForce( 0, -20, spaceship.x, spaceship.y)
		--ssk.actions.movep.thrustForward( spaceship, { rate = 1 } )
		--ssk.actions.movep.thrustForward( spaceship, { rate = spaceship.speed } )
		if(event.x > 350) then
			spaceship.rotation = -(event.x-350)*0.35
		elseif(event.x < 332) then
			spaceship.rotation = (332 - event.x)*0.35

		end

		--spaceship.x = event.x				--DEBUG: prev. used code

		--spaceship.rotation = (display.actualContentWidth/2 - event.x)*0.3
		--local angle  = spaceship.rotation
		--local newVec = angle2Vector( angle, true )
		--local scaledVec = scale( impulseVal , newVec )
		--spaceship:applyLinearImpulse( scaledVec.x, scaledVec.y, spaceship.x, spaceship.y)
		--touchjoint:setTarget( normDeltaX,normDeltaY)
		--spaceship.x =  event.x
		--spaceship:applyAngularImpulse( 10 )
		--_G.x = event.x
	end
end


function restart_game()

tcp.game_conn({TYPE = "IN_MATCH", RESTART = "TRUE", Tid = _G.Tid, Pindex = _G.Pindex, M = _G.matchmaking})
eoM.hideRestart()
modalEnd[3]:removeEventListener("tap",restart_game)

	-- TODO: DO RESTART SEQUENCE

end



function scene:show( event )
	local game_group = self.view
	local phase = event.phase

	if phase == "will" then
		--	background:addEventListener("touch",Moveship)
		background:addEventListener("touch",Moveship)

	elseif phase == "did" then
		composer.removeScene( "main_menu",false)
		print("Removing Menu scene")


	end
end

function scene:hide( event )
	local game_group = self.view
	local phase = event.phase

	if event.phase == "will" then

		--	physics.stop()
	elseif phase == "did" then

		--Runtime:removeEventListener("touch",Moveship)
	end

end

function scene:destroy( event )
camera:destroy()
	game_group:removeSelf() -- remove everything in this group
	game_group = nil
	for i = 1, #terrain do
        terrain[i]:removeSelf()
        terrain[i] = nil
        -- print to console to check that each is removed
        if terrain[i] == nil then
            print("TERRAIN ".. i .. " removed!")
        end
	end
		for i = 1, #players do
		        players[i]:removeSelf()
		        players[i] = nil
		        -- print to console to check that each is removed
		        if players[i] == nil then
		            print("PLAYERS ".. i .. " removed!")
		        end
			end

	modalEnd:removeSelf()
	world:removeSelf()
	spaceship:removeSelf()
	sidebar.removeAll()

	start=false
	_G.finished = false

print("CALLED DESTROY")
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


-----------------------------------------------------------------------------------------

return scene
