function drawHUD()
	local fontSize = hudFont:getHeight()
	print(fontSize)

	-- Kill count
	love.graphics.setColor(255,255,255,128)
	love.graphics.setFont(hudFont)
	love.graphics.print( "Kills: "..kills, 20, 20 )

	-- Ammo bar
	local barHeight = 32
	local barWidth = 400
	local xMargin = 20
	local yMargin = 20
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
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
