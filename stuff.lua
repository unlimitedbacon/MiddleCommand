function randPolygon(sides,rad,cx,cy)
	local points = {}
	for i = 1, sides do
		x = love.math.random(-rad,rad) + cx
		y = love.math.random(-rad,rad) + cy
		table.insert(points, x)
		table.insert(points, y)
	end
	return points
end

function onScreen(x,y)
	local wx = love.graphics.getWidth()
	local wy = love.graphics.getHeight()
	if x > 0 and x <= wx and y > 0 and y <= wy then
		return true
	else
		return false
	end
end

function checkCollision(canvas,x,y)
	if onScreen(x,y) then
		local imgData = canvas:newImageData(x,y,1,1)
		local r,_,_,_ = imgData:getPixel(0,0)
		if r == 0 then
			return false
		else
			return true
		end
	else
		return false
	end
end
