function drawNoise(infill)
	local w = love.graphics.getCanvas():getWidth()
	local h = love.graphics.getCanvas():getHeight()
	-- Could use love.math.setRandomSeed() to reproduce asteroids
	for x = 1,w do
		for y = 1,h do
			if love.math.random(0,100) <= infill then
				love.graphics.points(x-1,y-1)
			end
		end
	end
end

function smoothCanvas(canvas,low,high)
	local w = canvas:getWidth()
	local h = canvas:getHeight()
	local newCanvas = love.graphics.newCanvas(w,h)
	love.graphics.setCanvas(newCanvas)
	love.graphics.setShader(smoothShader)
	smoothShader:send("low",low)
	smoothShader:send("high",high)
	love.graphics.draw(canvas)
	love.graphics.setShader()
	love.graphics.setCanvas()
	return newCanvas
end

function scaleCanvas(potato,factor)
	local newCanvas = love.graphics.newCanvas()
	potato:setFilter("nearest","nearest")
	love.graphics.push()
	love.graphics.setCanvas(newCanvas)
	love.graphics.scale(factor,factor)
	love.graphics.draw(potato)
	love.graphics.setCanvas()
	love.graphics.pop()
	return newCanvas
end
