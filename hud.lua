function drawHUD()
	local xMargin = 20
	local yMargin = 20
	local fontSize = hudFont:getHeight()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	-- Kill count
	love.graphics.setColor(255,255,255,128)
	love.graphics.setFont(hudFont)
	love.graphics.print( "Kills: "..kills, xMargin, yMargin )
	-- Enemys remaining
	love.graphics.print( "Incoming Missiles: "..them.ammo, xMargin, yMargin+fontSize )
	-- Level
	love.graphics.printf( "Level: "..curLevelNum, 0, yMargin, w-xMargin, "right")

	-- Ammo bar
	local barHeight = 32
	local barWidth = 400
	-- TODO: If ammo > barWidth, double draw ammo bar
	if us.bases.left then
		love.graphics.rectangle( "line", xMargin-3, h-yMargin-barHeight-3, barWidth+6, barHeight+6 )
		love.graphics.setColor(255,0,0,128)
		love.graphics.rectangle( "fill", xMargin, h-yMargin-barHeight, us.bases.left.ammo, barHeight )
		love.graphics.print( us.bases.left.ammo, xMargin+3, h-yMargin-fontSize-math.ceil((barHeight-fontSize)/2))
	end
	if us.bases.right then
		love.graphics.setColor(255,255,255,128)
		love.graphics.rectangle( "line", w-xMargin-barWidth-3, h-yMargin-barHeight-3, barWidth+6, barHeight+6 )
		love.graphics.setColor(255,0,0,128)
		love.graphics.rectangle( "fill", w-xMargin-us.bases.right.ammo, h-yMargin-barHeight, us.bases.right.ammo, barHeight )
		love.graphics.printf( us.bases.right.ammo, w-xMargin-barWidth, h-yMargin-fontSize-math.ceil((barHeight-fontSize)/2), barWidth-3, "right")
	end
end
