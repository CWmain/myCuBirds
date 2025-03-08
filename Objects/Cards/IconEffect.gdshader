shader_type canvas_item;

uniform float radius = 0.3;

//Returns 1.0 if edge is shown, otherwise 0.0
float roundedEdge(vec2 position, float r){
	// Top left
	if (position.x < r && position.y < r){
		if (distance(position, vec2(r,r)) > r){
			return 0.0;
		}
	}
	// Top Right
	if (position.x > 1.0-r && position.y < r){
		if (distance(position, vec2(1.0-r,r)) > r){
			return 0.0;
		}
	}
	// Bottom left
	if (position.x < r && position.y > 1.0-r){
		if (distance(position, vec2(r,1.0-r)) > r){
			return 0.0;
		}
	}
	// Bottom Right
	if (position.x > 1.0-r && position.y > 1.0-r){
		if (distance(position, vec2(1.0-r,1.0-r)) > r){
			return 0.0;
		}
	}
	return 1.0;
}

void fragment() {
	COLOR[3] = roundedEdge(UV, radius);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
