local json = require "json"
local socket = require("socket")
--require("Networking.UDP")

local utility = {}
local host, port = "35.176.107.7", 41555
local tcp = nil

function utility.handshake_management()
tcp = assert(socket.tcp())

  if setConnection() then
   Handshake()      --Handshake start
   return true
 else
   native.showAlert( "Error", "Cannot connect to Server" ,{ "OK" })
   return false
end
end

function setConnection ()
  tcp:setoption("tcp-nodelay",true)     -- Disabling Nagle's algorithm, improving throughput speed
  tcp:setoption("keepalive",true)       -- Keepalive parameter to prevent the connection from closing
  tcp:setoption("reuseport", true)
  if tcp:connect(host, port) then
    return true
  else
    return false
  end
end

function Handshake()
  tcp:settimeout(0)       -- Setting timeout = 0 for non-blocking response
  tcp:setoption("tcp-nodelay",true)
  tcp:setoption("keepalive",true)
  tcp:send(json.encode({TYPE = 'HANDSHAKE'}))   --TCP packet is sent to the server (JSON FORMAT)
  tmr_initial_handshake = timer.performWithDelay( 200, function()   --Timer for response
      local x,y,message = tcp:receive()     --TCP receival process, returning TCP response
      if (json.decode(message)) then        -- Verifying json format of packet
        local jsn = json.decode(message)    -- Decoding JSON value
        if jsn.RES == "OK" and jsn.TYPE == "HANDSHAKE" then   -- Response from server has been received
          print("CONNECTED")
          _G.remoteAddress_TCP = jsn.IPADDRESS
          timer.cancel( tmr_initial_handshake )     -- Cancelling timer if response is OK
        else
          print("Awaiting response")
        end
      end
  end,0)
end

function utility.start_matchmaking4client()

  tcp:settimeout(0)     -- Setting timeout = 0 for non-blocking response
  tcp:send(json.encode({TYPE = "INIT_MATCHMAKING", USERNAME = _G.username}))
            --TCP packet is encoded in JSON and Teamname and Username are transmitted
  tmr_matchM = timer.performWithDelay( 200, function()    --Timer for response
    local x,y,message = tcp:receive()   --TCP receival process, returning TCP response
    if (json.decode(message)) then      -- Verifying json format of packet
      local jsn = json.decode(message)  -- Decoding JSON value
      if jsn.TYPE == "INIT_MATCHMAKING" and jsn.RES == "OK" then
        print("RECEIVED INIT MATCHMAKING JSON")
        timer.cancel(tmr_matchM)        --Cancelling timer if response is OK
        coroutine.resume(hide_matchmaking_initscreen)   --Hiding ChooseTeam screen
      end
    end
  end,0)


end
function utility.choose_team()

  tcp:settimeout(0)     -- Setting timeout = 0 for non-blocking response
  tcp:send(json.encode({TYPE = "CREATE_TEAM", NAME = _G.team_name, USERNAME = _G.username}))
            --TCP packet is encoded in JSON and Teamname and Username are transmitted
  tmr_team = timer.performWithDelay( 200, function()    --Timer for response
    local x,y,message = tcp:receive()   --TCP receival process, returning TCP response
    if (json.decode(message)) then      -- Verifying json format of packet
      local jsn = json.decode(message)  -- Decoding JSON value
      if jsn.TYPE == "CREATE_TEAM" and jsn.RES == "OK" then
        _G.is_host = jsn.ISHOST   --Saving isHost to global variable
        print("RECEIVED TEAM JSON")
        timer.cancel(tmr_team)        --Cancelling timer if response is OK
        coroutine.resume(hide_screen_choose_team)   --Hiding ChooseTeam screen
      end
    end
  end,0)
end

function utility.initial_game()

  tcp:settimeout(0)
  tcp:send(json.encode({TYPE = "START_MATCH"}))     --Start match from team host

  tmr_start = timer.performWithDelay(200, function()
    local x,y,message = tcp:receive()

    if(json.decode(message)) then
      local jsn = json.decode(message)

      if  jsn.TYPE == "MATCH" and jsn.RES == "OK" then
        print("RECEIVING INFO FROM SERVER")
        print("Closing HOST CONNECTION")
        timer.cancel( tmr_start )   --cancel host connection to server
      end
    end
  end,0)
end

function utility.game_conn(message)

  tcp:settimeout(0)
  tcp:send(json.encode(message))

  tmr_gm = timer.performWithDelay(20, function()

    local x,y,message = tcp:receive()

      if(json.decode(message)) then

        local jsn = json.decode(message)

      end

  end,0)
end


function utility.close_connection()
tcp:close()
print("DISCONNECTED")
end

return utility
