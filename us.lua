us = {}

us.bulletSpeed = 50
us.cooldown = 10

us.asteroids = {}
us.cities = {}
us.bases = {}
us.bullets = {}

function us:addAsteroid(infill, blockSize)
	asteroid = {}
	asteroid.x = love.math.random( love.graphics.getWidth()/4, love.graphics.getWidth()*3/4 )
	asteroid.y = love.math.random( love.graphics.getHeight()/4, love.graphics.getHeight()*3/4 )
	asteroid.rad = 200
	asteroid.color = {255,128,0,255}

	local w = love.graphics.getWidth() / blockSize
	local h = love.graphics.getHeight() / blockSize
	asteroid.canvas = love.graphics.newCanvas(w,h)

	asteroid.points = randPolygon(16, asteroid.rad, asteroid.x, asteroid.y)
	function drawPolygon()
		love.graphics.polygon( "fill", tableDiv(asteroid.points,blockSize) )
	end

	love.graphics.setCanvas(asteroid.canvas)
	love.graphics.stencil(drawPolygon,"replace",1)
	love.graphics.setStencilTest("greater",0)
	drawNoise(infill)
	love.graphics.setStencilTest()

	for x = 1,20 do
		asteroid.canvas = smoothCanvas(asteroid.canvas,4,4)
	end

	asteroid.canvas = scaleCanvas(asteroid.canvas,blockSize)

	for x = 1,4 do
		asteroid.canvas = smoothCanvas(asteroid.canvas,5,5)
	end

	love.graphics.setCanvas()
	table.insert(self.asteroids, asteroid)
end

function us:addCity(asteroid)
	city = {}
	local side = love.math.random( table.getn(asteroid.points) / 2 )
	-- Can we do something like points[side:side+1] instead?
	local x1 = asteroid.points[ side*2 - 1 ]
	local y1 = asteroid.points[ side*2 + 0 ]
	if side == table.getn(asteroid.points)/2 then
		x2 = asteroid.points[1]
		y2 = asteroid.points[2]
	else
		x2 = asteroid.points[ (side+1)*2 - 1 ]
		y2 = asteroid.points[ (side+1)*2 + 0 ]
	end
	local m = (y2-y1)/(x2-x1)
	local b = y1 - m*x1
	city.x = love.math.random( x1, x2 )
	city.y = m*city.x + b
	table.insert(self.cities, city)
end

function us:newBase()
	base = {}
	base.x = love.math.random( love.graphics.getWidth() )
	base.y = love.math.random( love.graphics.getHeight() )
	base.cooldown = 10
	base.bulletSpeed = 200

	function base:fire()
		if self.cooldown <= 0 then
			self.cooldown = 10
			local tx, ty = love.mouse.getPosition()
			bullet = newProjectile( "us", self.x, self.y, tx, ty, self.bulletSpeed )
			table.insert(us.bullets, bullet)
			love.audio.newSource("pop.ogg", "static"):play()
		end
	end

	return base
end
