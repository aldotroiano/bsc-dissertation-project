//																//
//
/*			 MATCHmaKING				  		*/
/*				Aldo Troiano				 		*/
//						2020								//


var db = require('./database_connection.js');
var dgram = require('dgram');
var server = dgram.createSocket('udp4');

var players = [];
var player = {};

server.on('error', (err) => {
console.log('server error: \n %s', err.stack);
server.close();
});

server.on('message', (msg,rinfo) => {
try{
	decoded_json = JSON.parse(msg);

	switch (decoded_json.TYPE){

  	case "INITIATE":
      	console.log('Received INITIATE MATCHMAKING from: %s:%s', rinfo.address,rinfo.port);
      	var addr = String(String(rinfo.address) + ":" + String(rinfo.port));
				send(JSON.stringify({TYPE : "INITIATE", RES : "OK"}),rinfo.address,rinfo.port);
				create_object(decoded_json.USERNAME,decoded_json.TCPADDRESS,addr);
    	break;

    	case "IN_GAME":
    	update_player(decoded_json.Tid,decoded_json.Pindex,decoded_json.x,decoded_json.y,decoded_json.health,decoded_json.rotation);
    	break;

		default:
			break;
	}
}
catch (error){
	console.log(error);
}

});

server.on('listening', () => {
	const address = server.address();
	console.log('Matchmaking UDP server listening on port: %s',address.port);
	setInterval(periodic_UDP,500);
	setInterval(MatchPlayers,5000);
	});

server.bind(55500);

function create_object(username,tcp,udp){
console.log("ADDED PLAYER to object");
player = {
	"pid" : players.length+1,
	"usr" : username,
	"tcp" : tcp,
	"udp" : udp,
}
players.push(player);
console.log(players);

}

function deletion_manager(tcpa){

var index_player;

for (var x = 0; x < players.length; x++){
	if(players[x].tcp == tcpa){

		players.splice(x,1);
		console.log("MATCHMAKING USER DELETED");
	}
}
}

function MatchPlayers(){
var playerIDS = [];
console.log('MATCHPLAYER FUNC');
if (players.length > 1){
	var counter = 0;
	players.forEach(player => {
			if(counter < 4 && players.length > 1){
			playerIDS.push(player);
			counter++;

			console.log("Added Player to temp team");
			console.log(playerIDS.length);
			if(counter==4 || playerIDS.length == players.length){
			counter = 0;
			console.log('INSELECTION');
			playerIDS.forEach(plyrTEMP => {players = players.filter(plyr => plyr.tcp !== plyrTEMP.tcp)});
			player_migration(playerIDS);
			playerIDS = [];}
		}
	});
	}
}

function fetch_players(IDS){		//Migration process from Team to Match

	var match_players = [];

	IDS.forEach(player => {

			match_players.push(player);

			var arr = (player.udp).split(":");
			send(JSON.stringify({TYPE : "INITPACK_GAME", RES : "OK", M : 1}),arr[0],arr[1]);			//Sending start packet to each of the team members


	});

return match_players;
}

function periodic_UDP(){

	for (var a = 0; a < players.length; a++){
		var addr = players[a].udp;
		var addr_s = addr.split(":");

		send(JSON.stringify({TYPE : "ROOM_MAKING", NPlayers : players.length}),addr_s[0],addr_s[1]);
	}
}

function send(msg,address,port){
	server.send(msg, port, address);
}


/* 																				*/
/* 																				*/
/* 					MATCHES FILE									*/
/* 																				*/

var map_gen = require('./map_generation.js');
var msgpack = require("msgpack-lite");
var matches = [];
var team = {};

setInterval(match_init,1200);
setInterval(in_match,50);

function player_migration(IDS){
	var match_array = fetch_players(IDS);
	//Previously called function for player migration from Player object to Team Array
	console.log("Length of team array = ",match_array.length);
	var count = 1;		//Index for Pid in Match object

team = { "Tid" : matches.length+1, "Pnum": match_array.length, "Status": 0, "totaly": 0 }
	//Team information, outside the player brackets. Universally accessible
match_array.forEach(player => {
	team[count] = {
	"Pid" : player.pid,
	"Host" : 0,
	"st" : 0,
	"Usr" : player.usr,
	"tcp" : player.tcp,
	"udp" : player.udp,
	"x" : 	count*(136.6),
	"y" : 600,
	"hp" : 100,
	"rot" : 0,
	"s" : 450,
	"f" : false,
	"r" : false,
	"pos" : count,
	}
	count++;
	});
//Match object pushed to Matches ARRAY
//One Object for each active match
matches.push(team);
console.log(matches);
return true;
}


function match_init(){
	matches.forEach(match => {
			//Looping through each of the Match objects in the Match array
switch (match.Status){				//Switch sending game-player info

case 0:
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		if(match[i].st == 0){
			send(JSON.stringify({TYPE : "INIT_GAME", STATUS : 1, Tid : match.Tid, Pindex : i,Pnum : match.Pnum}),arr[0],arr[1]);
		}
	}
	break;

case 1:
	console.log("Entered 1");
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		send(JSON.stringify({TYPE : "INIT_GAME", STATUS : 2, INFO: match}),arr[0], arr[1]);
		}
	break;

case 2:
	console.log("Entered 2");
	var map_data = map_gen.generate_obstacles();
	match.totaly = map_data[2] + 500;
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		send(JSON.stringify({TYPE : "INIT_GAME", STATUS : 3, OBSTACLES: map_data[0], ASTEROIDS: map_data[1], Y_TOTAL : map_data[2]+500 }),arr[0], arr[1]);
		}
	break;

case 3:
	console.log("Entered 3");
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		send(JSON.stringify({TYPE : "INIT_GAME", STATUS : 4}),arr[0], arr[1]);
		}
	break;

case 4:
	console.log("Entered 4 - Game starting");
	var tmstmp = new Date().getTime()/1000;
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		send(JSON.stringify({TYPE : "INIT_GAME", STATUS : 5, TIMESTAMP: Math.round(tmstmp)+4}),arr[0], arr[1]);
		}
	break;
	}

});
}

function in_match(){

matches.forEach(match => {

switch (match.Status){				//Switch sending game-player info

case 5:
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		send(msgpack.encode({"TYPE" : "GAME", "I" : match}),arr[0], arr[1]);
		}
	break;

case 6:
	for (var i = 1; i <= match.Pnum; i++){
		var arr = (match[i].udp).split(":");
		send(JSON.stringify({TYPE : "RESTART_GAME", STATUS : 0}),arr[0], arr[1]);
		}
	break;
	}


});
}

function update_status(Tid,Pindex,status){
//console.log("Updating status of Tid" + Tid + "and Pnum " + Pindex);

console.log("RECEIVED STATUS : " + status);
matches.forEach(match => {
if(match.Tid == Tid){
match[Pindex].st = status;		//Incrementing status variable
console.log("Increment status");

var sum = 0;
for(var i = 1; i <= match.Pnum; i++){ if(match[i].st == status){sum = sum + 1; }}
if(sum == match.Pnum){
 match.Status = status;
 console.log("SET GAME STATUS TO : " + match.Status);
 if(match.Status == 0){	// Restart match option, resetting default variables
 console.log("GOING THROUGH NEW OPTION");
 for(var i = 1; i <= match.Pnum; i++){
		match[i].x = i*(136.6);
		match[i].y = 600;
		match[i].hp = 100;
		match[i].rot = 0;
		match[i].s = 450;
		match[i].r = false;
		match[i].f = false;
		match[i].pos = i;
	}
 }
 }
}
console.log(match);
});

matches.forEach(match => {
	if(match.Tid == Tid){
			match[Pindex].st = status;		//Local global status var
			console.log("Increment status");

			var sum = 0;
			for(var i = 1; i <= match.Pnum; i++){ sum = sum + match[i].st; }
			if(sum/match.Pnum == status){ match.Status = status; }
			//If the Match players have the same status, the global Match Status is incremented
}
});
}

function update_player(Tid,Pindex,x,y,hp,rot){			//Update player positions and check if Finish line is reached

matches.forEach(match => {
if(match.Tid == Tid){
match[Pindex].x = x;
match[Pindex].y = y;
match[Pindex].hp = hp;
match[Pindex].rot = rot;
	if(match[Pindex].y < -match.totaly && match[Pindex].f != true){
		match[Pindex].f = true;

	}


if(match[Pindex].f == false){		//checking if reached finsih line and setting final position
	for (var f = 1;f <= match.Pnum; f++){
		for (var c = 1; c <= match.Pnum; c++){
			if (f != c){
				if (match[c].y < match[f].y && match[c].pos > match[f].pos){
					var temp = match[c].pos;
					match[c].pos = match[f].pos;
					match[f].pos = temp;
				}
			}

for (var f = 1;f <= match.Pnum; f++){
	for (var c = 1; c <= match.Pnum; c++){
		if (f != c){
		if (match[c].y < match[f].y && match[c].pos > match[f].pos){
		var temp = match[c].pos;
		match[c].pos = match[f].pos;
		match[f].pos = temp;
		}

		}
	}
}
}}}
}
});



}
function restart_match(Tid,Pindex){			//Restart match operation. Resettng match object and restarting from status 0

console.log("WANTS TO RESTART");

matches.forEach(match => {
if(match.Tid == Tid){
match[Pindex].r = true;		//Incrementing status variable
console.log("Increment status");

var sum = 0;
for(var i = 1; i <= match.Pnum; i++){ if(match[i].r == true){sum = sum + 1; }}
if(sum == match.Pnum){
match.Status = 6;
console.log("ALL OF PLAYERS WANT TO RESTART");
	for(var i = 1; i <= match.Pnum; i++){
		match[i].st = 6;
		match[i].x = i*(136.6);
		match[i].y = 600;
		match[i].hp = 100;
		match[i].rot = 0;
		match[i].s = 450;
		match[i].r = false;
		match[i].f = false;
		match[i].pos = i;
	}
}
}
//console.log(match);

});
}


module.exports = {send,deletion_manager,fetch_players,player_migration,update_status,update_player,restart_match};
