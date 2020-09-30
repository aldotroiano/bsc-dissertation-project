//																//
//
/*			 MAP GENERATION						*/
/*				Aldo Troiano				 		*/
//						2020								//

function random_calc(lower,higher){
return Math.floor(Math.random() * (higher - lower + 1) + lower)
}

function generate_obstacles(){
	var nObstacles = 2;		//original 200
	var nAsteroids = 1000;
	var total_y = 0;
	var sum = 0;
	
	var obstacles = new Array(nObstacles);
	var asteroids = new Array(nAsteroids);
	var y_total = 0;
	for (var i = 0; i < nObstacles ; i++ ){
		obstacles[i] = new Array(2);
		obstacles[i][0] = random_calc(50,615);
		var rand_y = random_calc(400,900);
		obstacles[i][1] = total_y + rand_y;
		total_y = total_y + rand_y;

	}

	for (var i = 0; i < nAsteroids; i++){

		asteroids[i] = new Array(2);
		asteroids[i][0] = random_calc(50,615);
		var rand_y = random_calc(150,300);
		asteroids[i][1] = sum + rand_y;
		sum = sum + rand_y;
		if(sum > total_y){ break;}
	
	}
	
	return [obstacles,asteroids,total_y];
	
}

module.exports = {generate_obstacles}
