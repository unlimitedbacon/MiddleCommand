function newAsteroid( infill, blockSize )
	asteroid = {}
	asteroid.color = {255,255,255,255}
	asteroid.canvas = {}
	-- Generate a random polygon shape and draw it to a canvas
	-- Polygons can also later be used for placing cities and collision detection

	-- Fill in said polygon based on designated infill percentage
	function asteroid:genMap()
		local w = love.graphics.getWidth() / blockSize
		local h = love.graphics.getHeight() / blockSize
		self.canvas = love.graphics.newCanvas(w,h)
		love.graphics.setCanvas(self.canvas)
		love.graphics.setColor(self.color)
		-- Could use love.math.setRandomSeed() to reproduce asteroids
		for x = 1,w do
			for y = 1,h do
				if love.math.random(0,100) <= infill then
					love.graphics.points(x-1,y-1)
				end
			end
		end
		love.graphics.setCanvas()
		love.graphics.setColor(255,255,255)
	end

	function asteroid:wallCount(cx,cy)
		-- Check 3x3 grid surrounding cx, cy
		local walls = 0
		local w = table.getn(self.map)
		local h = table.getn(self.map[1])
		for x = cx-1,cx+1 do
			for y = cy-1,cy+1 do
				if x~=cx or y~=cy then
					if x>0 and x<=w and y>0 and y<=w then
						if self.map[x][y] then
							walls = walls+1
						end
					end
				end
			end
		end
		return walls
	end

	-- Use cellular automato to smooth the bitmap
	-- based on this video https://www.youtube.com/watch?v=v7yyZZjF1z4
	function asteroid:smoothMap(low,high)
		local newMap = {}
		local w = table.getn(self.map)
		local h = table.getn(self.map[1])
		for x = 1,w do
			newMap[x] = {}
			for y = 1,h do
				walls = self:wallCount(x,y)
				if walls > high then
					newMap[x][y] = true
				elseif walls < low then
					newMap[x][y] = false
				else
					newMap[x][y] = self.map[x][y]
				end
			end
		end
		self.map = newMap
	end

	function asteroid:smoothCanvas(low,high)
		local w = self.canvas:getWidth()
		local h = self.canvas:getHeight()
		local newCanvas = love.graphics.newCanvas(w,h)
		love.graphics.setCanvas(newCanvas)
		love.graphics.setColor(self.color)
		love.graphics.setShader(smoothShader)
		smoothShader:send("low",low)
		smoothShader:send("high",high)
		love.graphics.draw(self.canvas)
		love.graphics.setCanvas()
		love.graphics.setShader()
		self.canvas = newCanvas
	end

	-- I think this is slow
	function asteroid:scaleMap()
		local newMap = {}
		local w = table.getn(self.map)
		local h = table.getn(self.map[1])
		for nx = 1,w*blockSize do
			newMap[nx] = {}
			for ny = 1,h*blockSize do
				x = ((nx-1) - (nx-1) % blockSize) / blockSize + 1
				y = ((ny-1) - (ny-1) % blockSize) / blockSize + 1
				newMap[nx][ny] = self.map[x][y]
			end
		end
		self.map = newMap
	end

	function asteroid:scaleCanvas()
		local newCanvas = love.graphics.newCanvas()
		self.canvas:setFilter("nearest","nearest")
		love.graphics.setCanvas(newCanvas)
		love.graphics.scale(blockSize,blockSize)
		love.graphics.draw(self.canvas)
		love.graphics.setCanvas()
		self.canvas = newCanvas
	end

	-- Draw map to a canvas
	function asteroid:genCanvas()
		local w = table.getn(self.map)
		local h = table.getn(self.map[1])
		self.canvas = love.graphics.newCanvas()
		love.graphics.setCanvas(self.canvas)
		love.graphics.setColor(self.color)
		for x = 1,w do
			for y = 1,h do
				if self.map[x][y] then
					--love.graphics.rectangle("fill",(x-1)*blockSize,(y-1)*blockSize,blockSize,blockSize)
					love.graphics.points(x-1,y-1)
					-- Might be faster if fed multiple points at once
				end
			end
		end
		love.graphics.setCanvas()
		love.graphics.setColor(255,255,255)
	end

	return asteroid
end

