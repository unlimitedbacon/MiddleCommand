extern number low;
extern number high;

vec4 effect( vec4 color, Image texture, vec2 tCoords, vec2 sCoords ){
	vec4 pixel;

	// These should probably be texture size, not screen size
	number pW = 1.0/love_ScreenSize.x;
	number pH = 1.0/love_ScreenSize.y;

	// Count the number of other pixels it is touching
	number walls = 0.0;
	vec4 tP;		// Test pixel
	number x;
	number y;

	// TODO: Still doesn't smooth near top and bottom for some reason
	for (int i=0; i<3; i++) {
		for (int j=0; j<3; j++) {
			x = tCoords.x - pW + (pW*float(i));
			y = tCoords.y - pH + (pH*float(j));
			if (i!=1 || j!=1) {
			// This check has to be done on ints,
			// because if you do it on the floats they will never ever be equal
				if (x>=0.0 && x<=1.0) {
					tP = Texel(texture, vec2(x,y));
					if (tP.r>0.0 || tP.g>0.0 || tP.b>0.0 || tP.a>0.0) {
						walls = walls + 1.0;
					}
				}
			}
		}
	}

	if (walls > high) {
		// Turn pixel on
		pixel = color;
	} else if (walls < low) {
		// Turn pixel off
		pixel = vec4(0.0,0.0,0.0,0.0);
	} else {
		// Leave pixel as is
		pixel = Texel(texture, tCoords);
	}

	return pixel;
}
