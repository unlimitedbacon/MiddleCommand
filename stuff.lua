function between(x,a,b)
	local min = math.min(a,b)
	local max = math.max(a,b)
	if x >= min and x <= max then
		return true
	else
		return false
	end
end

function intersect(x1,y1,x2,y2,x3,y3,x4,y4)
	m1 = (y2-y1) / (x2-x1)
	b1 = y1 - m1*x1
	m2 = (y4-y3) / (x4-x3)
	b2 = y3 - m2*x3
	if m1 == m2 then
		if b1 == b2 then
			return true
		else
			return false
		end
	end
	ix = (b2-b1) / (m1-m2)
	if between(ix,x1,x2) and between(ix,x3,x4) then
		return true
	else
		return false
	end
end

--function randPolygon(sides,rad,cx,cy)
--	local points = {}
--	for i = 1, sides do
--		x = love.math.random(-rad,rad) + cx
--		y = love.math.random(-rad,rad) + cy
--		table.insert(points, x)
--		table.insert(points, y)
--	end
--	return points
--end
function randPolygon(sides,rad,cx,cy)
	local points = {}
	local theta = 2*math.pi/sides
	local var = 40
	-- Create a circle
	local t = 0
	for s = 1, sides do
		points[s] = {}
		points[s].x = rad*math.cos(t) + cx
		points[s].y = rad*math.sin(t) + cy
		t = t + theta
	end
	-- Move points around randomly
	for s = 1, sides do
		local intersecting = true
		x = love.math.random(points[s].x-var,points[s].x+var)
		y = love.math.random(points[s].y-var,points[s].y+var)
		points[s].x = x
		points[s].y = y
	end
	-- Reformat for love.graphics.polygon()
	local npoints = {}
	for _, v in pairs(points) do
		table.insert(npoints, v.x)
		table.insert(npoints, v.y)
	end
	return npoints

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

function catTables(tableOfTables)
	local i = 1
	local new = {}
	for _,t in ipairs(tableOfTables) do
		for _,v in ipairs(t) do
			new[i] = v
			i = i + 1
		end
	end
	return new
end
