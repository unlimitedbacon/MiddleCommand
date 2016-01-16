extern Image explosionCanvas;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	//vec4 pixel = Texel(texture, texture_coords);
	vec4 pixel = color * Texel(texture, texture_coords);
	screen_coords.x = screen_coords.x / love_ScreenSize.x;
	screen_coords.y = screen_coords.y / love_ScreenSize.y;
	vec4 canvasPixel = Texel(explosionCanvas, screen_coords);
	if (canvasPixel.r != 0 && canvasPixel.g != 0) {
		if (canvasPixel.b != 0) {
			pixel.g = 0;
			pixel.b = 0;
		} else {
			pixel.g = 1;
			pixel.b = 1;
		}
	}
	return pixel;
}

