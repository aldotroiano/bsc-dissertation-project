local json = require "json"
local socket = require("socket")
require("Modals.Team_room")
require("gameplay.game_manager")
require("Modals.intermediary")
local tcp = require("Networking.TCP")
local msgpack = require "Libraries.msgpack.msgpack"     --using msgpack
local utility = {}
udp = socket.udp()
udp:settimeout(0)

function utility.startUDP(teamormatch)
  if(teamormatch == 0) then
    udp:setpeername("35.176.107.7", 55000)    --Team-based approach ip and port
  else
    udp:setpeername("35.176.107.7", 55500)    --Matchmaking approach ip and port
  end

  udp:send(json.encode({TYPE = 'INITIATE',USERNAME = _G.username, TCPADDRESS = _G.remoteAddress_TCP}))    --Initiate udp operations
  print("UDP STARTED")
  receive_room_participants()   --Start receiving room participants
end

function receive_room_participants()

tmr_room_part = timer.performWithDelay( 250, function()
  data = udp:receive()
  if data then
    if (json.decode(data)) then
      local jsn = json.decode(data)
        if has_key(jsn,"HOST0") then    --if room data is received
          update_room(jsn)      --update room contents
        end
        if jsn.TYPE == "ROOM_MAKING" then   --if matchmaking data is received
          matchmaking_room(jsn)       --update matchmaking available players details
      end
        if jsn.TYPE == "INITPACK_GAME" and jsn.RES == "OK" then   --Start match packet for all users to show game screen
          print("initpack")
          _G.matchmaking = jsn.M      --received matchmaking YES NO packet
          timer.cancel(tmr_room_part)
          game_stats()    --START UDP receival for match initialization and in-game
        end

    end
  end
end,0)
end

function game_stats()
  show_gm()         --Showing game on screen
  _G.ingame = false
  tmr_gamestats = timer.performWithDelay( 15, function()    --receival during game

      data = udp:receive()

      if data and _G.ingame == false then
        if (json.decode(data)) then
          local jsn = json.decode(data)

            if(jsn.TYPE == "INIT_GAME" and _G.Status == 0) then   --Status 1
              _G.Status = jsn.STATUS
              _G.Tid = jsn.Tid
              _G.Pindex = jsn.Pindex
              _G.Pnum = jsn.Pnum
              print("Status 1 confirmed")
              tcp.game_conn({TYPE = "CONFIRM_STATUS", STATUS = _G.Status, Tid = _G.Tid, Pindex = _G.Pindex, M = _G.matchmaking})
              update_message("(1) Connecting Players...")

          elseif(jsn.TYPE == "INIT_GAME" and _G.Status == 1 and jsn.STATUS > _G.Status) then
              print("Status 2 confirmed")
              _G.Status = jsn.STATUS

              player_generation(jsn.INFO)     --generate players on screen

              tcp.game_conn({TYPE = "CONFIRM_STATUS", STATUS = _G.Status, Tid = _G.Tid, Pindex = _G.Pindex, M = _G.matchmaking})
              update_message("(2) Receiving Player Data...")

          elseif(jsn.TYPE == "INIT_GAME" and _G.Status == 2 and jsn.STATUS > _G.Status) then
              print("Status 3 confirmed")
              _G.Status = jsn.STATUS
              tcp.game_conn({TYPE = "CONFIRM_STATUS", STATUS = _G.Status, Tid = _G.Tid, Pindex = _G.Pindex,  M = _G.matchmaking})
              terrain_generation(jsn.OBSTACLES,jsn.ASTEROIDS,jsn.Y_TOTAL)       --Inputting in game manager generated terrain

              update_message("(3) Receiving and Rendering Terrain...")

          elseif(jsn.TYPE == "INIT_GAME" and _G.Status == 3 and jsn.STATUS > _G.Status) then
              print("Status 4 confirmed")
              _G.Status = jsn.STATUS    --Save status and give time to low end devices to render terrain
              tcp.game_conn({TYPE = "CONFIRM_STATUS", STATUS = _G.Status, Tid = _G.Tid, Pindex = _G.Pindex, M = _G.matchmaking})
              update_message("(4) Synching Players...")

          elseif(jsn.TYPE == "INIT_GAME" and _G.Status == 4 and jsn.STATUS > _G.Status) then
              print("Status 5 confirmed - Starting Game")
              _G.Status = jsn.STATUS
              tcp.game_conn({TYPE = "CONFIRM_STATUS", STATUS = _G.Status, Tid = _G.Tid, Pindex = _G.Pindex, M = _G.matchmaking})
              server_start(jsn.TIMESTAMP)   --Receive timestamp of start
              update_message("(5) Starting Game...")
              _G.ingame = true    --flag variable to start sending data

            end
          end
        end

      if data and _G.ingame == true then    --If received data from Server. server update
        if not json.decode(data) then
          local O,jsn = msgpack.unpack(data)
              if(jsn.TYPE == "GAME") then
                  set_player_pos(jsn.I)       --Set players from game state
          end
        end
      end

      if _G.ingame == true then   --Send the server game updates of local player
       udp:send(json.encode({TYPE = 'IN_GAME',Tid = _G.Tid, Pindex = _G.Pindex, x = _G.x, y = _G.y, health = _G.health,rotation = _G.rotation}))
      end

      if data and _G.ingame == true and json.decode(data) then
        local jsn = json.decode(data)
        if(jsn.TYPE == "RESTART_GAME") then   --RESTART GAME OPERATIONS
          _G.Status = jsn.STATUS

          tcp.game_conn({TYPE = "CONFIRM_STATUS", STATUS = 0, Tid = _G.Tid, Pindex = _G.Pindex, M = _G.matchmaking})
          _G.ingame = false     --CONFIRM STATUS 0 to reset the match

          print("WENT THROUGH SERVER RESPONSE")

        restart_gm()    --reshow game screen dropping loaded entities
      end
      end

  end,0)
end

function utility.send(message)      --sending interface
  udp:send(json.encode(message))      --Sending UDP packet

end

function has_key(table, key)
    return table[key]~=nil
end



return utility
