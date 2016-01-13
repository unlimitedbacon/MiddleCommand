require "stuff"
require "graphics"
require "projectiles"
require "us"
require "them"

explodeRate = 25
explodeSize = 50

enemyDelay = 5.0
enemyDelayDecay = 0.99

gameOver = false
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
	asteroidImg = love.graphics.newImage('textures/asteroid.png')
	ourTrailImg = love.graphics.newImage('textures/redTrail.png')
	ourFlameImg = love.graphics.newImage('textures/redFlame.png')
	theirTrailImg = love.graphics.newImage('textures/blueTrail.png')
	theirFlameImg = love.graphics.newImage('textures/blueFlame.png')

	-- Generate Asteroids
	us:addAsteroid(60,4)
	us:addAsteroid(60,4)
	asteroidCanvas = love.graphics.newCanvas()
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
		--love.graphics.polygon("fill", a.points)
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.setStencilTest()
	love.graphics.setCanvas()

	us:addCity(us.asteroids[1])
	us:addCity(us.asteroids[2])

	us.bases.left = us.newBase()
	us.bases.right = us.newBase()
	if us.bases.left.x > us.bases.right.x then
		us.bases.left, us.bases.right = us.bases.right, us.bases.left
	end
	
	explosions = {}

	enemyCountdown = enemyDelay

	-- Ghosts are bullets/missiles that have detonated, but whose particle systems are still active
	ghosts = {}
	
	splosionCanvas1 = love.graphics.newCanvas()
	splosionCanvas2 = love.graphics.newCanvas()

	gameOverFont = love.graphics.newFont(64)
	hudFont = love.graphics.newFont(32)
end

function love.update(dt)
	if love.mouse.isDown(1) and us.bases.left then
		us.bases.left:fire()
	end
	if love.mouse.isDown(2) and us.bases.right then
		us.bases.right:fire()
	end

	for i,b in pairs(us.bases) do
		b.cooldown = b.cooldown - 1
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
end

function love.draw()
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setColor(255,255,255,255)

	-- Asteroids
	love.graphics.draw(asteroidCanvas)

	-- Cities
	love.graphics.setColor(255,255,255)
	for _,c in pairs(us.cities) do
		love.graphics.rectangle("fill", c.x-10, c.y-5, 20, 10)
	end

	-- Bases
	love.graphics.setColor(255,255,255)
	for _,b in pairs(us.bases) do
		love.graphics.circle("fill", b.x, b.y, 20, 6)
	end

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
	love.graphics.setBlendMode("alpha")
	-- For some reason, the canvas's colors are getting overridden
	love.graphics.setColor(255,255,0)
	love.graphics.draw(splosionCanvas2)
	
	love.graphics.setColor(255,255,255,128)
	love.graphics.setFont(hudFont)
	love.graphics.print( kills, 20, 20 )

	if gameOver then
		love.graphics.setColor(255,255,255,128)
		love.graphics.setFont(gameOverFont)
		love.graphics.printf( "YOU DIED", 0, love.graphics.getHeight()/2-32, love.graphics.getWidth() , "center" )
	end
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
end
