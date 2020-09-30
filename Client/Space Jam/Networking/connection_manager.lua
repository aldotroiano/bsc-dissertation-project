local udp = require("Networking.UDP")
local tcp = require("Networking.TCP")
local global = {}

function global.start_conn_tcp()    --Start TCP connection with server
  tcp.game_conn()   --tcp interface
end

function global.close_tcp_connection()      --Close TCp connection
  tcp.close_connection()
end

function global.init_tcp()  --Start handshake with serrver
  return tcp.handshake_management()
end

function global.init_udp(teamormatch)   --Start udp interface with team or match option
  udp.startUDP(teamormatch)
end

function global.initial_game_tcp()
  tcp.initial_game()    --confirm reception of tcp packet for show game screen
end

function global.choose_team_routine()
  tcp.choose_team()     --Confirm team through TCP interface
end

function global.init_matchmaking()    --Start matchmaking and show overlay
  tcp.start_matchmaking4client()
end

function global.udp_tcp_intermediary(message)   --Send confirmation status packet tcp to server
  tcp.game_conn(message)
end






return global
