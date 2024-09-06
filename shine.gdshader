shader_type canvas_item;

// Just a quick note for future me on how to get int pixel position
// int pix_pos = int(UV.y * TEXTURE_PIXEL_SIZE.y);
// int height = int(1.0/TEXTURE_PIXEL_SIZE.y);
// int pix_pos = int(UV.y * float(height));

/**
 * Upper and lower limit of the flash so if glow_center is at some y then
 * glow will reach out from y - flash_bound to y + flash_bound
 */
uniform float shine_bound = 0.2;
uniform float shine_strength = 0.3;
uniform float shine_frequency = 0.25;

void fragment() {
	/**
	 * Below is quite some vodoo magic so I will try to explain it:
	
	 *     fract(TIME * shine_frequency)......
	 * 
	 * Above part will get us a kind of triangular wave with frequency equal to
	 * shine_frequency. This is nice because it gives us time dependent function
	 * with values in [0, 1] range, so it is perfect for positioning glow_center.
	 *
	 *     ...... * (1.0 + 2.0 * shine_bound) - shine_bound;
	 * 
	 * Well it's almost perfect. If the shine moves between exactly [0, 1] the
	 * animation will work but it will look choppy, because the shine will
	 * instantly appear at 0.0 and disapear at 1.0. To aid that we can move the
	 * shine slightly before 0.0 and slightly after 1.0 so it smoothly disappears
	 * and appears. The above part does just that. We scale the position we got
	 * from earlier so it can fit 2 times flash_bound and shift it down by single
	 * flash_bound. So after that glow_center will be in range:
	 * [0.0 - flash_bound, 1.0 + flash_bound].
	 */
	float shine_center = fract(TIME * shine_frequency) * (1.0 + 2.0 * shine_bound) - shine_bound;
	
	/**
	 * Below is little bit more straight forward. We get distance between pixel
	 * and shine center and we scale the shine depending on the distance from
	 * distance_from_shine_center. Bigger the distance, lower the "shine" value.
	 * And we cut out entirely after shine_bound.
	 */
	float distance_from_shine_center = abs(UV.y - shine_center);
	if (distance_from_shine_center < shine_bound) {
		float shine;
		shine = -smoothstep(0.0, shine_bound, distance_from_shine_center) + 1.0;
		COLOR.rgb = clamp(COLOR.rgb + shine * shine_strength, 0.0, 1.0);
	}
}