require("game_engine")
tablex = require("Libraries.tablex")
local json = require "json"
--require("Networking.connection_manager")
--require("Networking.TCP")
--local composer = require( "composer" )

function stats_receive(jsn)

print("Received Game stat")
  if jsn.TYPE == "INITPACK_GAME" then
--composer.showOverlay( "game_engine", {effect = "fade", time = 200})
  end
end


function update_message(message)
set_status_message(message)
end

function terrain_generation(obstacles,asteroids,y_total)
  spawnEnd(y_total)   --Spawning finish line
for i = 1, #obstacles, 1 do
    spawnObstacle(obstacles[i][1],obstacles[i][2])
end
for i = 1, #asteroids, 1 do
  spawnAsteroid(asteroids[i][1],asteroids[i][2])
end
-- Spawning terrain entities from 2D arrays
end

function player_generation(tbl)

print("Got playerinfo")

for i = 1,_G.Pnum,1 do

  if(i == _G.Pindex) then
    spawnPlayerMain(tbl[tostring(i)].x,tbl[tostring(i)].y)    --spawn main player
    _G.totaly = tbl.totaly
    spawnSidebarMain(i,tbl[tostring(i)].y)    --spawn player on sidebar
  else
    spawnPlayers(i,tbl[tostring(i)].x,tbl[tostring(i)].y,tbl[tostring(i)].Usr)    --spawn opponents
    spawnSidebarOpponent(i,tbl[tostring(i)].y)    --spawn opponents on sidebar
  end
end
end

function server_start(timestamp)
  local ost = os.time(os.date("*t"))
  local rem_time = (timestamp - ost)
  -- Subtracting local timestamp from server timestamp for start time
  print(TIME_UNTIL_START)
  updateTimer_start(rem_time)
end

function set_player_pos(tbl)
_G.totaly = tbl.totaly
setPlayers(tbl)
end

function reset_gameman()
reset_game()
end
