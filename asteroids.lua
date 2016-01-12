function newAsteroid( infill )
	-- Generate a random polygon shape and draw it to a canvas


	-- Fill in said polygon based on designated infill percentage
	local map = {}
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	-- Could use love.math.setRandomSeed() to reproduce asteroids
	for x = 1,w do
		map[x] = {}
		for y = 1,h do
			if love.math.random(100) > infill then
				map[x][y] = false
			else
				map[x][y] = true
			end
		end
	end

	-- Draw map to a canvas
	local canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(255,128,0)
	for x = 1,w do
		for y = 1,h do
			if map[x][y] then
				love.graphics.point(x,y)
				-- Might be faster if we could use love.graphics.points()
			end
		end
	end
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255)

	return canvas
end
