require "levels"
require "stuff"
require "graphics"
require "projectiles"
require "us"
require "them"
require "hud"
require "ui"
require "game"

explodeRate = 40
explodeSize = 50

curLevelNum = 1
gameOver = false
kills = 0

function love.load()
	-- Loading Screen
	backgroundImg = love.graphics.newImage('textures/starfield.png')
	messageFont = love.graphics.newFont(64)
	love.graphics.draw(backgroundImg)
	textInABox("Loading...")
	love.graphics.present()

	-- Check System Specs
	os = love.system.getOS()
	print(os)
	for k,v in pairs(love.graphics.getSystemLimits()) do
		print(k,v)
	end
	if love.graphics.getSystemLimits()['multicanvas'] > 1 then
		multicanvas = true
	else
		multicanvas = false
	end
	
	-- Load Shaders
	explosionShader = love.graphics.newShader("shaders/explosionShader.glsl")
	smoothShader = love.graphics.newShader("shaders/smoothShader.glsl")
	maskShader = love.graphics.newShader("shaders/mask.glsl")
	--glowShader = love.graphics.newShader("shaders/glow.glsl")

	-- Load Textures
	asteroidImg = love.graphics.newImage('textures/asteroid.png')
	baseImg = love.graphics.newImage('textures/base.png')
	baseImgW = baseImg:getWidth()
	baseImgH = baseImg:getHeight()
	baseOutlineImg = love.graphics.newImage('textures/baseOutline.png')
	cityImg = love.graphics.newImage('textures/city.png')
	ourTrailImg = love.graphics.newImage('textures/redTrail.png')
	ourFlameImg = love.graphics.newImage('textures/redFlame.png')
	theirTrailImg = love.graphics.newImage('textures/blueTrail.png')
	theirFlameImg = love.graphics.newImage('textures/blueFlame.png')

	-- Load Fonts
	hudFont = love.graphics.newFont(32)

	-- Setup Canvases
	-- asteroidCanvas also has cities and bases
	-- Basically, it includes everything you can hit
	asteroidCanvas = love.graphics.newCanvas()
	-- Explosions are swapped between canvases in order to force the GPU to serialize drawing
	splosionCanvas1 = love.graphics.newCanvas()
	splosionCanvas2 = love.graphics.newCanvas()

	-- Load level
	loadLevel(curLevelNum)
end

function love.update(dt)
	-- Only check for mouse presses on a PC,
	-- because on touches register as mouse clicks on Android
	if os ~= "Android" and os~= "iOS" then
		if love.mouse.isDown(1) and us.bases.left then
			us.bases.left:fire()
			us.selectedBase = us.bases.left
		end
		if love.mouse.isDown(2) and us.bases.right then
			us.bases.right:fire()
			us.selectedBase = us.bases.right
		end
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

	-- See if you lost
	if table.getn(us.cities) == 0 then
		gameOver = true
	end

	-- See if you won
	if them.ammo == 0 and table.getn(them.missiles) == 0 and not gameOver then
		levelWon = true
	end

	-- Load next level if you won and pressed enter
	if levelWon and love.keyboard.isDown('return') then
		curLevelNum = curLevelNum + 1
		loadLevel(curLevelNum)
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setColor(255,255,255,255)

	-- Starfield
	love.graphics.draw(backgroundImg)

	-- Outline around selected base
	if us.selectedBase then
		love.graphics.setCanvas()
		--love.graphics.setShader(glowShader)
		--glowShader:send("size",{baseImgW,baseImgH})
		love.graphics.setColor({255,0,0,255})
		love.graphics.draw(baseOutlineImg, us.selectedBase.x, us.selectedBase.y, 0, 1, 1, math.ceil(baseImgW/2), math.ceil(baseImgH/2))
		--love.graphics.setShader()
		love.graphics.setColor({255,255,255,255})
	end

	-- Asteroids, Cities, and Bases
	love.graphics.draw(asteroidCanvas)

	-- Bullets
	drawProjectiles(us.bullets,255,0,0)

	-- Enemy missiles
	drawProjectiles(them.missiles,0,0,255)

	-- Ghosts
	drawGhosts()

	-- Explosions
	drawExplosions()
	
	-- HUD
	drawHUD()

	if gameOver then
		textInABox("YOUR DIED")
	end
	if levelWon and not gameOver then
		textInABox("YOU WIN\nPress Enter")
	end
end

function love.touchpressed( id, x, y, dx, dy, pressure )
	for _,b in ipairs(us.bases) do
		if x > b.x-baseImgW and x < b.x+baseImgW then
			if y > b.y-baseImgH and y < b.y+baseImgH then
				us.selectedBase = b
				return
			end
		end
	end
	us.selectedBase:fire()
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
end
