function uiBox(x,y,w,h)
	love.graphics.setColor(0,0,0,64)
	love.graphics.rectangle( "fill", x, y, w, h )
	love.graphics.setColor(252,192,36,224)
	love.graphics.rectangle( "line", x, y, w, h )
end
