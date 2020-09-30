-- This class will hold all of the spaceships for the game_engine
local physics = require "physics"
local O = {}
local colors = {"0000ff","ff0000","00ff00","00ffff"}
local composer = require "composer"
require "Libraries.Hex2RGB"

function O.new(world,i,x,y,name)

local full_opponent = display.newGroup()

--Spawning opponents with physics
local sheet_firespace = graphics.newImageSheet( "Assets/spaceship.png", {width=85, height=149, numFrames = 8}  )
  local body = display.newSprite( sheet_firespace, {start=1, count=8, time=400, loopCount=0,loopDirection="forward"} )
  body:setFillColor(hex2rgb(colors[i]))
  body.x ,body.y = x,y
  body.fill.effect = "filter.brightness"
  body.fill.effect.intensity = 0.6

	body.anchorY, body.anchorX = 0.5,0.5


  body:play()

  full_opponent:insert(body)

  local name = display.newText(world,tostring(name),body.x+4,body.y+88,"fonts/FallingSky.otf",14 )
  name.anchorX = 0.5
  name:setFillColor(255,255,255)

  full_opponent:insert(name)
  local outline = { 0,-78,  18,-60,  35,50, -30,50, -13,-60 }
  physics.addBody(body, "dynamic",{shape = outline, density=45,friction=0,bounce=0})

  body.isSleepingAllowed = false
  body.myName = "opponent"

  world:insert(full_opponent)

  return full_opponent
end
return O
