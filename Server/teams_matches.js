var db = require('./database_connection.js');
//var matches = require('./matches.js');
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
      	console.log('Received INITIATE UDP from: %s : %s', rinfo.address,rinfo.port);
      	var addr = String(String(rinfo.address) + ":" + String(rinfo.port));
      	db.initiate_udp(decoded_json.TCPADDRESS,addr).then(function([player_id,team_id,is_host,username]){
				send(JSON.stringify({TYPE : "INITIATE", RES : "OK"}),rinfo.address,rinfo.port);
				create_object(player_id,team_id,is_host,username,decoded_json.TCPADDRESS,addr);
				});
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
	console.log('UDP server listening on port: %s',address.port);
	setInterval(periodic_UDP,500);
	});

server.bind(55000);

function create_object(player_id,team_id,is_host,username,tcp,udp){
console.log("ADDED PLAYER to object");
player = {
	"Tid" : team_id,
	"Pid" : player_id,
	"usr" : username,
	"host" : is_host,
	"tcp" : tcp,
	"udp" : udp,
}
players.push(player);
console.log(players);
//periodic_UDP();
}

function deletion_manager(tcpa){

var index_player;

for (var x = 0; x < players.length; x++){
	if(players[x].tcp == tcpa){

		if(players[x].host == 1){
		change_host(tcpa,players[x].Tid);

		}
		players.splice(x,1);
		console.log("DELETED HOST FROM ARRAY");
	}
}

console.log(players.length);
}

function change_host(tcpa_old,team_id){

	for (var i = 0; i < players.length; i++){

		if(players[i].tcp != tcpa_old && players[i].Tid == team_id){
			players[i].host = 1;
			break;
		}
	}
}

function fetch_players(HOSTremoteAddress){		//Migration process from Team to Match
	var team_id;
	var match_players = [];
	players.forEach(player => { if(player.tcp == HOSTremoteAddress){team_id = player.Tid;}});

	players.forEach(player => {
		if(team_id == player.Tid){
			match_players.push(player);

			console.log("TEAMS: ", players);

			var arr = (player.udp).split(":");
			send(JSON.stringify({TYPE : "INITPACK_GAME", RES : "OK", M : 0}),arr[0],arr[1]);			//Sending start packet to each of the team members
			players = players.filter(plyr => plyr.tcp !== player.tcp);
		}
	});

return match_players;
}

function periodic_UDP(){

	for (var a = 0; a < players.length; a++){
		var addr = players[a].udp;
		var addr_s = addr.split(":");
		var tID = players[a].Tid;
		var tmp_nm = [];
		var tmp_ishost = [];

		for(var b = 0; b < players.length; b++){
			if(players[b].Tid == tID){
				tmp_nm.push(players[b].usr);
				tmp_ishost.push(players[b].host);
			}
		}
		var jsn = "{";
		for (var x = 0; x < tmp_nm.length; x++){
		jsn += "\"NAME"+x+"\" : \""+ tmp_nm[x] + "\", \"HOST"+x+"\" : "+ tmp_ishost[x] +",";
		}
		send(jsn+"}",addr_s[0],addr_s[1]);
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

function player_migration(HOSTremoteAddress){
	var match_array = fetch_players(HOSTremoteAddress);
	//Previously called function for player migration from Player object to Team Array
	console.log("Length of team array = ",match_array.length);
	var count = 1;		//Index for Pid in Match object

team = { "Tid" : match_array[0].Tid, "Pnum": match_array.length, "Status": 0, "totaly": 0 }
	//Team information, outside the player brackets. Universally accessible
match_array.forEach(player => {
	team[count] = {
	"Pid" : player.Pid,
	"Host" : player.host,
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
 if(match.Status == 0){
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
});

//console.log(match);


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

function update_player(Tid,Pindex,x,y,hp,rot){

matches.forEach(match => {
if(match.Tid == Tid){
match[Pindex].x = x;
match[Pindex].y = y;
match[Pindex].hp = hp;
match[Pindex].rot = rot;
	if(match[Pindex].y < -match.totaly && match[Pindex].f != true){
		match[Pindex].f = true;

	}


if(match[Pindex].f == false){
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
function restart_match(Tid,Pindex){

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
