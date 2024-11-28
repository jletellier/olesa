shader_type canvas_item;

const float EPSILON = 0.2;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D palette_default : repeat_disable, filter_nearest;
uniform sampler2D palette_swap : repeat_disable, filter_nearest;

vec4 swap_color(vec4 color) {
	int palette_size = textureSize(palette_default, 0).x;

	for (int i = 0; i < palette_size; i++) {
		vec3 original_color = texelFetch(palette_default, ivec2(i, 0), 0).rgb;
		vec3 new_color = texelFetch(palette_swap, ivec2(i, 0), 0).rgb;
		if (distance(color.rgb, original_color) < EPSILON) {
			return vec4(new_color, color.a);
		}
	}
	return color;
}

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR = swap_color(c);
}
