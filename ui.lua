function textInABox(string)
	local xm = 8
	local ym = 6
	local w = messageFont:getWidth(string)
	local h = messageFont:getHeight(string)
	local n = 1
	for i in string:gmatch("\n") do
		n = n + 1
	end
	h = h * n
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	love.graphics.setColor(0,0,0,64)
	love.graphics.rectangle( "fill", sw/2-w/2-xm, sh/2-h/2-ym, w+2*xm, h+2*ym )
	love.graphics.setColor(252,192,36,224)
	love.graphics.rectangle( "line", sw/2-w/2-xm, sh/2-h/2-ym, w+2*xm, h+2*ym )
	love.graphics.setFont(messageFont)
	love.graphics.setColor(255,255,255,128)
	love.graphics.printf( string, 0, sh/2-h/2, sw, "center")
end
