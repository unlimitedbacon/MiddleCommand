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

-- This method uses a shader to cycle through 3 different colors (yellow, white, red).
-- Davidobot provided another method using stencils (https://love2d.org/forums/viewtopic.php?f=4&t=81482&start=10#p192791)
-- that would probably be more elegant, but I don't see a way to make it cycle from yellow, to white, to red and then back to yellow again.
function drawExplosions()
	love.graphics.setColor(255,255,0)
	love.graphics.setShader(explosionShader)
	-- Draw to two canvases on systems that can handle it
	-- in order to avoid excessive canvas switching
	if multicanvas then
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
	else
		love.graphics.setCanvas(splosionCanvas1)
		love.graphics.clear(0,0,0,0)
		love.graphics.setCanvas(splosionCanvas2)
		love.graphics.clear(0,0,0,0)
		for _,e in pairs(explosions) do
			love.graphics.setCanvas(splosionCanvas1)
			explosionShader:send("explosionCanvas",splosionCanvas2)
			love.graphics.circle("fill", e.x, e.y, e.rad, 32)
			love.graphics.setCanvas(splosionCanvas2)
			explosionShader:send("explosionCanvas",splosionCanvas1)
			love.graphics.circle("fill", e.x, e.y, e.rad, 32)
			splosionCanvas1, splosionCanvas2 = splosionCanvas2, splosionCanvas1
			-- Using two canvases and swapping them forces the GPU to flush the render queue.
			-- Otherwise, it tries to start drawing the second circle
			-- before drawing of the first circle is finished.
			-- https://love2d.org/forums/viewtopic.php?t=81482
		end
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
	love.graphics.draw(splosionCanvas1)
	love.graphics.setBlendMode("alpha")
end
