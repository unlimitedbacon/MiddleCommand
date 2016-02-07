function loadLevel(levelNum)
	-- Load level
	curLevel = levels[levelNum]
	levelWon = false
	enemyDelay = curLevel.enemyDelay
	enemyDelayDecay = curLevel.enemyDelayDecay
	enemyCountdown = enemyDelay
	them.ammo = curLevel.theirAmmo

	-- Generate Asteroids
	us.asteroids = {}
	for i=1, curLevel.numAsteroids do
		us:addAsteroid(60,4)
	end
	love.graphics.setCanvas(asteroidCanvas)
	love.graphics.clear()
	local currentAsteroid = {}
	function asteroidStencil()
		love.graphics.setShader(maskShader)
		love.graphics.draw(currentAsteroid.canvas)
		love.graphics.setShader()
	end
	for _,a in pairs(us.asteroids) do
		currentAsteroid = a
		love.graphics.stencil(asteroidStencil, "replace", 1, true)
		love.graphics.setStencilTest("greater", 0)
		love.graphics.setColor(a.color)
		love.graphics.draw(asteroidImg)
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.setStencilTest()
	-- Asteroid debugging stuff
	--love.graphics.setColor(255,0,0)
	--for _,a in pairs(us.asteroids) do
	--	love.graphics.polygon("line", a.points)
	--	love.graphics.circle("fill", a.x, a.y, 5, 10)
	--end

	-- Generate Cities
	us.cities = {}
	for i=1, curLevel.numCities do
		x = love.math.random(curLevel.numAsteroids)
		us:addCity(us.asteroids[x])
	end
	-- Draw cities to asteroid canvas
	cityImgW = cityImg:getWidth()
	cityImgH = cityImg:getHeight()
	love.graphics.setColor(255,255,255)
	for _,c in pairs(us.cities) do
		love.graphics.draw(cityImg, c.x, c.y, c.angle, 1, 1, cityImgW/2, cityImgH-5)
		--love.graphics.rectangle("fill", c.x-10, c.y-5, 20, 10)
	end

	-- Generate Bases
	us.bases = {}
	us.bases.left = us.newBase()
	us.bases.right = us.newBase()
	us.bases[1] = us.bases.left
	us.bases[2] = us.bases.right
	if us.bases.left.x > us.bases.right.x then
		us.bases.left, us.bases.right = us.bases.right, us.bases.left
	end
	-- Draw bases to asteroid canvas
	baseImgW = baseImg:getWidth()
	baseImgH = baseImg:getHeight()
	love.graphics.setColor(255,255,255)
	for _,b in pairs(us.bases) do
		love.graphics.draw(baseImg, b.x, b.y, 0, 1, 1, baseImgW/2, baseImgH/2)
		--love.graphics.circle("fill", b.x, b.y, 20, 6)
	end

	love.graphics.setCanvas()
	
	-- Ghosts are bullets/missiles that have detonated, but whose particle systems are still active
	ghosts = {}
	explosions = {}
end
