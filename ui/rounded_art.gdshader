shader_type canvas_item;

uniform vec2 rect_size = vec2(800.0, 400.0);
uniform float corner_radius = 26.0;

void fragment() {
	vec2 p = UV * rect_size;
	vec2 half_size = rect_size * 0.5;
	vec2 d = abs(p - half_size) - (half_size - vec2(corner_radius));
	float dist = length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0) - corner_radius;
	float mask = 1.0 - smoothstep(-1.0, 0.5, dist);
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.rgb, tex.a * mask);
}
