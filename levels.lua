levels = {}

levels[1] = {
	enemyDelay = 5.0,	-- Initial delay between creation of enemy missiles
	enemyDelayDecay = 0.99,	-- Rate of decay (per missile fired) of enemy delay
	numAsteroids = 2,	-- Number of Asteroids
	numCities = 2,		-- Number of cities
	ourAmmo = 400,		-- Starting ammo given to each base
	theirAmmo = 10,	-- Number of enemy missiles that get fired before the level ends
	targetBases = false	-- Whether or not enemies will target the missile bases in addition to the cities
}

levels[2] = {
	enemyDelay = 4.0,
	enemyDelayDecay = 0.99,
	numAsteroids = 3,
	numCities = 3,
	ourAmmo = 400,
	theirAmmo = 20,
	targetBases = true
}
