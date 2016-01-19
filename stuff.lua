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
		local r,g,b,a = imgData:getPixel(0,0)
		-- By not checking the alpha channel, this allows us to have
		-- invisble objects
		if (r == 0 and g==0 and b==0) then
			return false
		else
			return true
		end
	else
		return false
	end
end

function tableDiv(t,num)
	local nT = {}
	for _,x in pairs(t) do
		table.insert(nT, x/num)
	end
	return nT
end
