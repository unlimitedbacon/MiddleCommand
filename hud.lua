function drawHUD()
	-- Kill count
	love.graphics.setColor(255,255,255,128)
	love.graphics.setFont(hudFont)
	love.graphics.print( kills, 20, 20 )

	-- Ammo bar
	local barHeight = 32
	local barWidth = 400
	local xMargin = 20
	local yMargin = 20
	-- TODO: If ammo > barWidth, double draw ammo bar
	if us.bases.left then
		love.graphics.rectangle( "line", xMargin-3, love.graphics.getHeight()-yMargin-barHeight-3, barWidth+6, barHeight+6 )
		love.graphics.setColor(255,0,0,128)
		love.graphics.rectangle( "fill", xMargin, love.graphics.getHeight()-yMargin-barHeight, us.bases.left.ammo, barHeight )
	end
	if us.bases.right then
		love.graphics.setColor(255,255,255,128)
		love.graphics.rectangle( "line", love.graphics.getWidth()-xMargin-barWidth-3, love.graphics.getHeight()-yMargin-barHeight-3, barWidth+6, barHeight+6 )
		love.graphics.setColor(255,0,0,128)
		love.graphics.rectangle( "fill", love.graphics.getWidth()-xMargin-us.bases.right.ammo, love.graphics.getHeight()-yMargin-barHeight, us.bases.right.ammo, barHeight )
	end
end
