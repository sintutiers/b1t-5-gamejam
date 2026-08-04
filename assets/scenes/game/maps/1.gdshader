shader_type canvas_item;

uniform vec2 light_pos = vec2(0.5);
uniform int shape_type = 0;
uniform float circle_radius = 100.0;
uniform vec2 rect_half_extents = vec2(100.0, 100.0);
uniform float rect_rotation = 0.0;
uniform float dither_size = 200;

const float bayer_matrix[64] = float[64](
	0.0/64.0, 32.0/64.0,  8.0/64.0, 40.0/64.0,  2.0/64.0, 34.0/64.0, 10.0/64.0, 42.0/64.0,
	48.0/64.0, 16.0/64.0, 56.0/64.0, 24.0/64.0, 50.0/64.0, 18.0/64.0, 58.0/64.0, 26.0/64.0,
	12.0/64.0, 44.0/64.0,  4.0/64.0, 36.0/64.0, 14.0/64.0, 46.0/64.0,  6.0/64.0, 38.0/64.0,
	60.0/64.0, 28.0/64.0, 52.0/64.0, 20.0/64.0, 62.0/64.0, 30.0/64.0, 54.0/64.0, 22.0/64.0,
	3.0/64.0, 35.0/64.0, 11.0/64.0, 43.0/64.0,  1.0/64.0, 33.0/64.0,  9.0/64.0, 41.0/64.0,
	51.0/64.0, 19.0/64.0, 59.0/64.0, 27.0/64.0, 49.0/64.0, 17.0/64.0, 57.0/64.0, 25.0/64.0,
	15.0/64.0, 47.0/64.0,  7.0/64.0, 39.0/64.0, 13.0/64.0, 45.0/64.0,  5.0/64.0, 37.0/64.0,
	63.0/64.0, 31.0/64.0, 55.0/64.0, 23.0/64.0, 61.0/64.0, 29.0/64.0, 53.0/64.0, 21.0/64.0
);

float sdOrientedBox(in vec2 point, in vec2 half_extents, in float angle) {
	float c = cos(angle);
	float s = sin(angle);
	vec2 local = vec2(point.x * c + point.y * s, -point.x * s + point.y * c);
	vec2 d = abs(local) - half_extents;
	return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void fragment() {
	vec2 offset = FRAGCOORD.xy - light_pos;

	float dist;
	if (shape_type == 1) {
		dist = sdOrientedBox(offset, rect_half_extents, rect_rotation);
	} else {
		dist = length(offset) - circle_radius;
	}

	float dither_threshold = bayer_matrix[int(mod(FRAGCOORD.x, 8.0)) + int(mod(FRAGCOORD.y, 8.0)) * 8];
	float dithered_edge = dist / dither_size;
	float darkness = step(dither_threshold, dithered_edge);

	COLOR = vec4(COLOR.rgb, darkness * COLOR.a);
}