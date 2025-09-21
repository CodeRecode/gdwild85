shader_type spatial;

uniform vec3 grass_mult: source_color;
uniform sampler2D grass_tex: source_color;
uniform vec2 grass_scale = vec2(10.);

uniform vec3 dirt_mult: source_color;
uniform sampler2D dirt_tex;
uniform vec2 dirt_scale = vec2(10.);

uniform vec3 rock_mult: source_color;
uniform sampler2D rock_tex;
uniform vec2 rock_scale = vec2(10.);

uniform sampler2D dirt_blend_tex;
uniform sampler2D rock_blend_tex;

void fragment() {
	vec3 grass_color = texture(grass_tex, UV * grass_scale).rgb * grass_mult;
	vec3 dirt_color = texture(dirt_tex, UV * dirt_scale).rgb * dirt_mult;
	vec3 rock_color = texture(rock_tex, UV * rock_scale).rgb * rock_mult;

	float dirt_blend = texture(dirt_blend_tex, UV).r;
	float rock_blend = texture(rock_blend_tex, UV).r;

	vec3 color_1 = mix(grass_color, dirt_color, dirt_blend);
	vec3 color_2 = mix(color_1, rock_color, rock_blend);
	if (OUTPUT_IS_SRGB) {
		ALBEDO = color_2;
	}
	else {
		ALBEDO = vec3(0.);
	}
	ROUGHNESS = 1.;
}