//																//
//
/*			 DB CONNECTION						*/
/*				Aldo Troiano				 		*/
//						2020								//

const sqlite3 = require('sqlite3'), TransactionDatabase = require('sqlite3-transactions').TransactionDatabase;
let db = null;
var create_connection = function(){

	db = new TransactionDatabase(new sqlite3.Database('./db/database',sqlite3.OPEN_READWRITE,(err) => {
		if (err) {

			console.log('DATABASE CONNECTION ERROR. FILE NOT FOUND');
			console.error(err.message);
			process.exit(1);
		}
		console.log('Connected to Database');
	}));

}

function add_player(remoteAddress,player_name){
	var query_insert = "INSERT INTO ONLINE_PLAYERS('TCP ADDRESS') VALUES ('"+ remoteAddress +"');";
	//INSERT INTO DATABASE (ONLINE_PLAYERS) TABLE
	db.exec(query_insert, function(err) {		//Execute query
		if (err) {
			console.error(err.message);
		}
	});
	//console.log("Added player to Table ONLINE_PLAYERS")
}

function remove_player(remoteAddress){		//Remove player from ONLINEPLAYERS TABLE

	var query_delete = "DELETE FROM ONLINE_PLAYERS WHERE \"TCP Address\" = '"+ remoteAddress +"';";

	db.exec(query_delete, function(err) {
		if (err) {
			console.error(err.message);
		}
	});
	//	console.log("Deleted player from Table ONLINE_PLAYERS")
}

function player_exists(remoteAddress){		//Count online playerss
	var SQLquery = "SELECT COUNT(*) AS Count FROM ONLINE_PLAYERS WHERE \"TCP Address\" = '" +  remoteAddress + "';";

	return new Promise((resolve, reject) => {
		db.get(SQLquery, (err,resp) => {
			if(err) { console.log(err);
				reject(err); }
				if(JSON.parse(resp.Count) == 1){
					resolve(1);
				}
				else{ resolve(0); }
			});
		});
	}

	function in_a_team(player_id){		//Count players in a team
		var SQLquery = "SELECT COUNT(*) AS Count FROM TEAM_PLAYER WHERE PLAYER_ID_FK  = '" +  player_id + "';";

		return new Promise((resolve, reject) => {
			db.get(SQLquery, (err,resp) => {
				if(err) { console.log(err);
					reject(err); }
					if(JSON.parse(resp.Count) == 1){
						resolve(true);
					}
					else{ resolve(0); }
				});
			});
		}

		function add_to_team(player_id,team_name,username){		//Add to team transaction

			return new Promise((resolve, reject) => {

				db.beginTransaction(function(err,transaction){
					transaction.run("UPDATE ONLINE_PLAYERS SET Name = \""+ username +"\" WHERE ID = "+ player_id +";")
					transaction.run("INSERT INTO TEAM_PLAYER (\"TEAM ID_FK\",PLAYER_ID_FK,is_Host) VALUES ((SELECT Team_ID FROM TEAMS 			WHERE Team_name = \""+ team_name +"\"),"+ 			player_id +",(CASE WHEN (SELECT COUNT(*) is_Host FROM TEAM_PLAYER 			WHERE \"TEAM ID_FK\" = (SELECT Team_ID FROM TEAMS 			WHERE Team_name = \""+ team_name +"\") AND 			is_Host = 1) = 0 THEN 1 ELSE 0 END));")

					transaction.commit(function (err){
						if(err) { reject(err); }
						resolve("done");
					});
				});
			});
		}

		function create_team(player_id,team_name,username){			//Create team on database transaction promise

			return new Promise((resolve, reject) => {

				db.beginTransaction(function(err,transaction){
					transaction.run("UPDATE ONLINE_PLAYERS SET Name = \""+ username +"\" WHERE ID = "+ player_id +";")
					transaction.run("INSERT INTO TEAMS (Team_name) VALUES (\""+ team_name +"\");");
					transaction.run("INSERT INTO TEAM_PLAYER (\"TEAM ID_FK\",PLAYER_ID_FK,is_Host) VALUES (last_insert_rowid(),"+ 			player_id +",(CASE WHEN (SELECT COUNT(*) is_Host FROM TEAM_PLAYER WHERE \"TEAM ID_FK\" = last_insert_rowid() AND 			is_Host = 1) = 0 THEN 1 ELSE 0 END));")

					transaction.commit(function (err){
						if(err) { reject(err); }
						resolve("done");
					});
				});
			});}

			function get_player_ID(remoteAddress){		//get player id
			console.log(remoteAddress);
				var SQLquery = "SELECT ID as id FROM ONLINE_PLAYERS WHERE \"TCP ADDRESS\" = \"" +  remoteAddress + "\" ";

				return new Promise((resolve, reject) => {
					db.get(SQLquery, (err,resp) => {
						if(err) { reject(err); }

						resolve(JSON.parse(resp.id))
					});
				});
			}

			function get_username(pid){			//Get username of player

				var SQLquery = "SELECT Name AS username FROM ONLINE_PLAYERS WHERE \"ID\" = " +  pid + ";";

				return new Promise((resolve, reject) => {
					db.get(SQLquery, (err,resp) => {
						if(err) { reject(err); }

						resolve(resp.username);
					});
				});
			}


			function is_host(player_id){			//Check if player is host
				var SQLquery = "SELECT is_Host AS ishost FROM TEAM_PLAYER WHERE PLAYER_ID_FK = \"" + player_id + "\"";
				return new Promise((resolve, reject) => {
					db.get(SQLquery, (err,resp) => {
						if(err) { reject(err); }
						resolve(JSON.parse(resp.ishost))
					});
				});

			}

			function Player_in_team(team_name){			//Player in team check. to select host
				var SQLquery = "SELECT COUNT(*) AS Count FROM TEAMS WHERE TEAM_NAME = \"" +  team_name + "\"";

				return new Promise((resolve, reject) => {
					db.get(SQLquery, (err,resp) => {
						if(err) { console.log(err);
							reject(err); }
							resolve(JSON.parse(resp.Count))
						});
					});
				}


				function selecthost_and_leave(team_id,player_id,remoteAddress){					//Select new host once player leaves room and is host

					return new Promise((resolve, reject) => {

						db.beginTransaction(function(err,transaction){
							transaction.run("UPDATE TEAM_PLAYER SET is_Host = 0 WHERE is_Host = 1 AND \"TEAM ID_FK\" = \"" + team_id + "\" AND PLAYER_ID_FK = \"" + player_id + "\"");
							transaction.run("UPDATE TEAM_PLAYER SET is_Host = 1 WHERE \"TEAM ID_FK\" = \"" + team_id + "\" AND PLAYER_ID_FK = (SELECT PLAYER_ID_FK FROM TEAM_PLAYER WHERE PLAYER_ID_FK <> \"" + player_id + "\" AND \"TEAM ID_FK\" = \"" + team_id + "\" AND is_Host = 0 LIMIT 1)");

							transaction.run("DELETE FROM TEAM_PLAYER WHERE PLAYER_ID_FK = \"" + player_id + "\" AND \"TEAM ID_FK\" = \"" + team_id + "\"")
							transaction.run("DELETE FROM ONLINE_PLAYERS WHERE \"TCP ADDRESS\" = \"" + remoteAddress + "\"")

							transaction.commit(function (err){
								if(err) { reject(err); }
								resolve(true);
							});
						});
					});
				}

				function delete_player_from_team(team_id,player_id,remoteAddress){			//delete player from team

					return new Promise((resolve, reject) => {

						db.beginTransaction(function(err,transaction){

							transaction.run("DELETE FROM TEAM_PLAYER WHERE PLAYER_ID_FK = \"" + player_id + "\" AND \"TEAM ID_FK\" = \"" + team_id + "\"")
							transaction.run("DELETE FROM ONLINE_PLAYERS WHERE \"TCP ADDRESS\" = \"" + remoteAddress + "\"")

							transaction.commit(function (err){
								if(err) { reject(err); }
								resolve(true);
							});
						});
					});
				}
				function delete_team(team_id,player_id,remoteAddress){		//deleate full team if empty

					return new Promise((resolve, reject) => {

						db.beginTransaction(function(err,transaction){
							transaction.run("DELETE FROM TEAM_PLAYER WHERE PLAYER_ID_FK = \"" + player_id + "\" AND \"TEAM ID_FK\" = \"" + team_id + "\"")
							transaction.run("DELETE FROM TEAMS WHERE TEAM_ID = '" + team_id + "';")
							transaction.run("DELETE FROM ONLINE_PLAYERS WHERE \"TCP ADDRESS\" = \"" + remoteAddress + "\"")


							transaction.commit(function (err){
								if(err) { reject(err); }
								resolve(true);
							});
						});
					});
				}

				function check_for_team_mates(team_id){
					var SQLquery = "SELECT COUNT(*) AS number FROM TEAM_PLAYER WHERE \"TEAM ID_FK\" = \"" +  team_id + "\"";

					return new Promise((resolve, reject) => {
						db.get(SQLquery, (err,resp) => {
							if(err) {
								console.log(err);
								reject(err); }
								if(JSON.parse(resp.number) > 1){
									resolve(1);
								}
								else{
									resolve(0);
								}
							});
						});
					}


					function get_team_ID(player_id){
						var SQLquery = "SELECT \"Team ID_FK\" AS id FROM TEAM_PLAYER WHERE \"PLAYER_ID_FK\" = '" +  player_id + "';";

						return new Promise((resolve, reject) => {
							db.get(SQLquery, (err,resp) => {
								if(err) { console.log(err);
									reject(err); }
									resolve(JSON.parse(resp.id))
								});
							});
						}


						function team_creation_adding(remoteAddress,team_name,username){

							return new Promise((resolve, reject) => {		//Promise processes
								get_player_ID(remoteAddress).then(function(player_id) {		//Retreiving playerID from Remote Address
									Player_in_team(team_name).then(function(team_exists) {	//Returns number of players in team if exists
										if(team_exists == 1){			//if Team already exists
											add_to_team(player_id,team_name,username).then(function(){		//Set player to teamID
												//console.log("ADDED TO TEAM");			//Debug output
												is_host(player_id).then(function(ishost){		//Retreive isHost value from TEAM_PLAYER
													resolve(ishost);			//Return isHost value to main function
												});
											});
										}
										else if(team_exists == 0){			//If team does not exists
											create_team(player_id,team_name,username).then(function(){	//Create the team in the Database
												//console.log("TEAM CREATED");
												is_host(player_id).then(function(ishost){		//Retreive isHost value from TEAM_PLAYER
													resolve(ishost);		//Return isHost value to main function
												});
											});}},
									function(err){
										console.log(err);
										reject();
									});});});
						};

						function leave_room(remoteAddress){

							return new Promise((resolve, reject) => {
								var team_ID_global; var player_ID_global;
								get_player_ID(remoteAddress).then(function(player_id) { 	//Retreive player_id
									player_ID_global = player_id;
									in_a_team(player_id).then(function(isinteam){
										if(isinteam){
											is_host(player_id).then(function(ishost){				//Retrieve is_host value
												if(ishost == 1){					//Check whether exiting Player is Room host
													get_team_ID(player_id).then(function(team_id){	//Retrieve Team ID
														team_ID_global = team_id;
														check_for_team_mates(team_id).then(function(resp){ 	//Retrieve 1 if NOT alone in team, 0 otherwise
															if(resp == 1){				//Other people in the team
																selecthost_and_leave(team_id, player_id, remoteAddress).then(function(val){
																	if (val) { resolve("OK") }
																	else{ reject(0)}
																});
															}
															else if(resp == 0){			//Leaving team with only one occupier, should delete team
																delete_team(team_id,player_id,remoteAddress).then(function(val){
																	console.log("PROMISE THAT DELETES TEAM");
																	if (val) { resolve ("OK") }
																	else { reject(0) }
																});
															}});
														});}
														else if(ishost == 0){			//If exiting player is NOT host
															get_team_ID(player_id).then(function(team_id){	//Retrieve Team ID
																delete_player_from_team(team_id,player_ID_global,remoteAddress).then(function(val){
																	if (val) {resolve ("OK")}
																	else { reject (0) }
																});
															});

														}
													});
												}
												else{
													resolve();
												}
											});
										});

									});
								}



								function initiate_udp(tcp_address,udp_address) {

									var SQL_update = ("UPDATE ONLINE_PLAYERS SET \"UDP ADDRESS\" = '" + String(udp_address) + "' WHERE \"TCP ADDRESS\" = '"+ String(tcp_address) +"';");
									return new Promise((resolve, reject) => {
										db.run(SQL_update, function(err) {
											if (err) {
												console.log(err.message);
												reject();
											}
											get_player_ID(tcp_address).then(function(player_id) { 	//Retreive player_id
												get_username(player_id).then(function(username){
													get_team_ID(player_id).then(function(team_id){	//Retrieve Team ID
														is_host(player_id).then(function(is_host){				//Retrieve is_host value
															resolve([player_id,team_id,is_host,username]);
														});
													});
												});
											});
										});
									});


								}


								module.exports = {create_connection,add_player,remove_player,get_player_ID,player_exists,team_creation_adding,leave_room,initiate_udp};
