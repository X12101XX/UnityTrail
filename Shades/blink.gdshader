shader_type canvas_item;
uniform float blink_level: hint_range(0.0, 1.0, 0.1);
uniform vec4 blink_color: source_color;

void fragment() {
	vec4 origin_color = texture(TEXTURE, UV);
	
	COLOR = origin_color + blink_color * blink_level;
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
