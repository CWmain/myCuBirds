shader_type canvas_item;

uniform float radius = 0.3;

void fragment() {
	// Top left
	if (UV.x < radius && UV.y < radius){
		if (distance(UV, vec2(radius,radius)) > radius){
			COLOR = vec4(0,0,0,0);
		}
	}
	// Top Right
	if (UV.x > 1.0-radius && UV.y < radius){
		if (distance(UV, vec2(1.0-radius,radius)) > radius){
			COLOR = vec4(0,0,0,0);
		}
	}
	// Bottom left
	if (UV.x < radius && UV.y > 1.0-radius){
		if (distance(UV, vec2(radius,1.0-radius)) > radius){
			COLOR = vec4(0,0,0,0);
		}
	}
	// Bottom Right
	if (UV.x > 1.0-radius && UV.y > 1.0-radius){
		if (distance(UV, vec2(1.0-radius,1.0-radius)) > radius){
			COLOR = vec4(0,0,0,0);
		}
	}
	
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
