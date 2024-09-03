shader_type canvas_item;

void fragment() {
	// Column wise so sobel[column][row]
	mat3 sobel_x = mat3(
		vec3(1.0, 2.0, 1.0),
		vec3(0.0, 0.0, 0.0),
		vec3(-1.0, -2.0, -1.0)
	);
	float convolution = 0.0;
	for (float column = 0.0; column < 3.0; column++) {
		for (float row = 0.0; row < 3.0; row++) {
			// Fetch neighboring pixel
			vec3 neighbor = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x * column, TEXTURE_PIXEL_SIZE.y * row)).rgb;
			float neighbor_mono = (0.2125 * neighbor.r) + (0.7154 * neighbor.g) + (0.0721 * neighbor.b); 
			convolution += neighbor_mono * sobel_x[int(column)][int(row)];
		}
	}
	
	// Clamp because values are surely of magintude > 1.0
	// abs because "more negative" values also indicate edges
	COLOR.rgb = vec3(0.0, 0.0, 0.0);
	COLOR.b = abs(clamp(convolution, -0.5, 0.5));
	
	// Pseudo 3D / Pseudo normal map
	// Made it by accident but looks cool
	//COLOR.b = clamp(acc, -0.5, 0.5) + 0.5;
}
