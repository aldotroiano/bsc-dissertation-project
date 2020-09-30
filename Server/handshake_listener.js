//																//
//
/*			 TCP INTERFACE						*/
/*				Aldo Troiano				 		*/
//						2020								//



var db = require('./database_connection.js');
//var matches = require('./matches.js');
var teams = require('./teams_matches.js');
var matchmaking = require('./matchmaking.js');
var start_listener = function(){

var net = require('net');
var counter = 0

// Configuration parameters
var HOST = '0.0.0.0';
var PORT = 41555;

// Create Server instance
var server = net.createServer(onClientConnected);

server.listen(PORT, HOST, function() {
  console.log('TCP server listening on: %s', PORT);
});

function onClientConnected(sock) {

  var remoteAddress = sock.remoteAddress + ':' + sock.remotePort;   //Showing the Remote address opening the connection
  counter = counter + 1;
  console.log('NEW CONNECTED CLIENT: %s', remoteAddress);   //Debug output
  //console.log('Connected clients: %i', counter);          //Debug output

  sock.on('data', function(data) {        //Function called once a socket is opened for incoming data

	try{
	decoded_json = JSON.parse(data);       //Parsing JSON message

	switch (decoded_json.TYPE){            //Switch on different data Types

  case "HANDSHAKE":                     //If client requests handshake
      console.log('Received IH from: %s', remoteAddress);
      db.add_player(remoteAddress);     //DB function called to register user
      sock.write(JSON.stringify({TYPE : "HANDSHAKE", RES : "OK", IPADDRESS: remoteAddress}));
    break;          //Writing to the Client through Socket (OK,TCP remote address)

  	case "KEEPALIVE":
		console.log('Received KAP from: %s', remoteAddress);
    	sock.write(JSON.stringify({TYPE : "KEEPALIVE", RES : "OK"}));    //Previously used. Unused in final version
		break;

	case "CREATE_TEAM":      //create team packet

		db.team_creation_adding(remoteAddress,decoded_json.NAME,decoded_json.USERNAME).then(function(isHost){
                  //Promise for database writing (Appending row to Team_PLAYER)
		sock.write(JSON.stringify({TYPE : "CREATE_TEAM", RES : "OK", ISHOST: isHost})); //Client response (OK,isHost(0 or 1))
		console.log("PACKET SENT");     //Debug output
		});
		break;

	case "LEAVE_ROOM":     //leave room packet
		db.leave_room(remoteAddress,decoded_json.NAME).then(function(ok){
		sock.write(JSON.stringify({TYPE : "LEAVE_ROOM", RES : "OK"}));
		console.log("PLAYER LEFT ROOM");
		counter -= 1;
		teams.deletion_manager(remoteAddress);
		});
		break;

		case "START_MATCH":   //start match packet from host
		  sock.write(JSON.stringify({TYPE : "MATCH", RES : "OK"}));
		    teams.player_migration(remoteAddress);
		      console.log("HOST IS TRYING TO START MATCH");
		break;

		case "IN_MATCH":    //in match receival to restart the match

		  sock.write(JSON.stringify({TYPE : "IN_MATCH", RES : "OK"}));
		    if (decoded_json.M == 1){
		          matchmaking.restart_match(decoded_json.Tid,decoded_json.Pindex);
		   }else{
  		           teams.restart_match(decoded_json.Tid,decoded_json.Pindex);}
		break;

		case "INIT_MATCHMAKING":
		sock.write(JSON.stringify({TYPE : "INIT_MATCHMAKING", RES : "OK"}));
		//matchmaking.createUser(remoteAddress,decoded_json.USERNAME);
		console.log("RECEIVED REQUEST FROM MATCH USER");
		break;

		case "CONFIRM_STATUS":
		//console.log("Confirming status of single player");
		if(decoded_json.M == 1){    //if matchmakign packet confirm status
		matchmaking.update_status(decoded_json.Tid,decoded_json.Pindex,decoded_json.STATUS);}
		else{     //if team packet confirm status
		teams.update_status(decoded_json.Tid,decoded_json.Pindex,decoded_json.STATUS);
		}
	default:
		break;
}
}
catch (error){
console.log(error);
}
  });


  sock.on('close',  function () {
 		try{
		db.player_exists(remoteAddress).then(function(exists){

			if(exists == 1){     //Delete team from database if connection is clsoed and team member is 1
				db.leave_room(remoteAddress).then(function(ok){
		 		db.remove_player(remoteAddress);
    		counter = counter - 1;
    		console.log('connection from %s closed', remoteAddress);
  			console.log('Connected clients: %i', counter);
  			teams.deletion_manager(remoteAddress);
  			matchmaking.deletion_manager(remoteAddress);
				});
			}
			else{
			console.log('connection from %s closed', remoteAddress);
			console.log('Connected clients: %i', counter);
			}
		});
		}
		catch(e){
		console.log(e);
		}
  });


  sock.on('error', function (err) {
    console.log('Connection %s error: %s', remoteAddress, err.message);
  });
};
}

module.exports = {start_listener};
