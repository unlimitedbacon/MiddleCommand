require "levels"
require "stuff"
require "graphics"
require "projectiles"
require "us"
require "them"
require "hud"
require "ui"

explodeRate = 40
explodeSize = 50

curLevelNum = 1
gameOver = false
levelWon = false
kills = 0

function love.load()
	-- Load Shaders
	explosionShaderCode = love.filesystem.read("shaders/explosionShader.glsl")
	explosionShader = love.graphics.newShader( explosionShaderCode )
	smoothShaderCode = love.filesystem.read("shaders/smoothShader.glsl")
	smoothShader = love.graphics.newShader( smoothShaderCode )
	maskShaderCode = love.filesystem.read("shaders/mask.glsl")
	maskShader = love.graphics.newShader( maskShaderCode )

	-- Load Textures
	backgroundImg = love.graphics.newImage('textures/starfield.png')
	asteroidImg = love.graphics.newImage('textures/asteroid.png')
	baseImg = love.graphics.newImage('textures/base.png')
	cityImg = love.graphics.newImage('textures/city.png')
	ourTrailImg = love.graphics.newImage('textures/redTrail.png')
	ourFlameImg = love.graphics.newImage('textures/redFlame.png')
	theirTrailImg = love.graphics.newImage('textures/blueTrail.png')
	theirFlameImg = love.graphics.newImage('textures/blueFlame.png')

	-- Load Fonts
	gameOverFont = love.graphics.newFont(64)
	hudFont = love.graphics.newFont(32)

	-- Setup Canvases
	-- asteroidCanvas also has cities and bases
	-- Basically, it includes everything you can hit
	asteroidCanvas = love.graphics.newCanvas()
	-- Explosions are swapped between canvases in order to force the GPU to serialize drawing
	splosionCanvas1 = love.graphics.newCanvas()
	splosionCanvas2 = love.graphics.newCanvas()

	-- Load level
	curLevel = levels[curLevelNum]
	enemyDelay = curLevel.enemyDelay
	enemyDelayDecay = curLevel.enemyDelayDecay
	enemyCountdown = enemyDelay
	them.ammo = curLevel.theirAmmo

	-- Generate Asteroids
	for i=1, curLevel.numAsteroids do
		us:addAsteroid(60,4)
	end
	love.graphics.setCanvas(asteroidCanvas)
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

function love.update(dt)
	if love.mouse.isDown(1) and us.bases.left then
		us.bases.left:fire()
	end
	if love.mouse.isDown(2) and us.bases.right then
		us.bases.right:fire()
	end

	for i,b in pairs(us.bases) do
		b.cooldownTimer = b.cooldownTimer - dt
		if checkCollision(splosionCanvas1,b.x,b.y) then
			explode(b.x,b.y)
			us.bases[i] = nil
		end
	end
	
	for i,b in pairs(us.cities) do
		if checkCollision(splosionCanvas1,b.x,b.y) then
			explode(b.x,b.y)
			table.remove(us.cities, i)
		end
	end
	
	updateProjectiles(us.bullets,dt)
	updateProjectiles(them.missiles,dt)
	updateGhosts(dt)

	for i,e in pairs(explosions) do
		if e.embiggening then
			e.rad = e.rad + explodeRate * dt
			if e.rad >= explodeSize then
				e.embiggening = false
			end
		else
			e.rad = e.rad - explodeRate * dt
			if e.rad <= 0 then
				table.remove(explosions, i)
			end
		end
	end

	enemyCountdown = enemyCountdown - dt
	if enemyCountdown <= 0 and table.getn(us.cities) > 0 then
		enemyCountdown = enemyDelay
		enemyDelay = enemyDelay * enemyDelayDecay
		them:fire()
	end

	if table.getn(us.cities) == 0 then
		gameOver = true
	end

	if them.ammo == 0 and table.getn(them.missiles) == 0 and not gameOver then
		levelWon = true
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setColor(255,255,255,255)

	-- Starfield
	love.graphics.draw(backgroundImg)

	-- Asteroids, Cities, and Bases
	love.graphics.draw(asteroidCanvas)

	-- Bullets
	drawProjectiles(us.bullets,255,0,0)

	-- Enemy missiles
	drawProjectiles(them.missiles,0,0,255)

	-- Ghosts
	drawGhosts()

	-- Explosions
	love.graphics.setColor(255,255,0)
	love.graphics.setShader(explosionShader)
	love.graphics.setCanvas(splosionCanvas1,splosionCanvas2)
	love.graphics.clear()
	for _,e in pairs(explosions) do
		love.graphics.setCanvas(splosionCanvas1,splosionCanvas2)
		explosionShader:send("explosionCanvas",splosionCanvas1)
		love.graphics.circle("fill", e.x, e.y, e.rad, 32)
		splosionCanvas1, splosionCanvas2 = splosionCanvas2, splosionCanvas1
		-- Using two canvases and swapping them forces the GPU to flush the render queue.
		-- Otherwise, it tries to start drawing the second circle
		-- before drawing of the first circle is finished.
		-- https://love2d.org/forums/viewtopic.php?t=81482
	end
	love.graphics.setShader()
	-- Remove chunks of asteroid
	love.graphics.setCanvas(asteroidCanvas)
	love.graphics.setColor(0,0,0,0)
	love.graphics.setBlendMode("replace")
	for _,e in pairs(explosions) do
		love.graphics.circle("fill", e.x, e.y, e.rad, 32)
	end
	love.graphics.setCanvas()
	love.graphics.setBlendMode("add")
	-- Use subtract for a cloaking device effect
	love.graphics.setColor(255,255,255)
	love.graphics.draw(splosionCanvas2)
	love.graphics.setBlendMode("alpha")
	
	drawHUD()

	if gameOver then
		uiBox( love.graphics.getWidth()/2-170, love.graphics.getHeight()/2-32, 340, 72 )
		love.graphics.setColor(255,255,255,128)
		love.graphics.setFont(gameOverFont)
		love.graphics.printf( "YOU DIED", 0, love.graphics.getHeight()/2-32, love.graphics.getWidth() , "center" )
	end
	if levelWon and not gameOver then
		uiBox( love.graphics.getWidth()/2-170, love.graphics.getHeight()/2-32, 340, 72 )
		love.graphics.setColor(255,255,255,128)
		love.graphics.setFont(gameOverFont)
		love.graphics.printf( "YOU WIN", 0, love.graphics.getHeight()/2-32, love.graphics.getWidth() , "center" )
	end
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
end
