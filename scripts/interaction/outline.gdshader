shader_type canvas_item;
uniform bool selected = false;
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec2 d = TEXTURE_PIXEL_SIZE;
	float edge = max(max(texture(TEXTURE,UV+vec2(d.x,0.0)).a, texture(TEXTURE,UV-vec2(d.x,0.0)).a),max(texture(TEXTURE,UV+vec2(0.0,d.y)).a,texture(TEXTURE,UV-vec2(0.0,d.y)).a));
	COLOR = selected && pixel.a < 0.1 && edge > 0.5 ? vec4(1.0) : pixel;
}
