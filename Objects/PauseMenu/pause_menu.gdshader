shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float blurSize = 100.0;

uniform vec2 resolution = vec2(128.0,72.0);

void fragment() {
	vec2 texelSize = 1.0 / resolution;
	vec3 blurColor = vec3(0.0);
	float boxBlurDivisor = pow(2.0 * blurSize + 1.0, 2.0);
	float count = 1.0;
	for (float u = -blurSize; u <= blurSize; u++){
		for (float v = -blurSize; v <= blurSize; v++){
			blurColor += textureLod(screen_texture, SCREEN_UV + (vec2(u,v) * texelSize), 0.0).rgb;
			count++;
			
			// Prevent infinite looping
			if (count > 10000.0){
				break;
			}
		}
		
		// Prevent infinite looping
		if (count > 10000.0){
			break;
		}
	}
	COLOR.rgb = blurColor / boxBlurDivisor;
	
	
	// Called for every pixel the material is visible on.
}

