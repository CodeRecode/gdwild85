shader_type spatial;

uniform vec2 dir1 = vec2(1.0, 0.0);
uniform vec2 dir2 = vec2(0.0, 1.0);
uniform float speed: hint_range(0.0, 1.0) = .1;

uniform vec3 albedo: source_color = vec3(1.0);
uniform sampler2D normal_map: filter_linear;
uniform sampler2D normal_map2: filter_linear;

void fragment() {
	vec2 offset = dir1 * speed * TIME;
	vec2 offset2 = dir2 * speed * TIME;
	vec3 normal = texture(normal_map, UV + offset).rgb;
	vec3 normal2 = texture(normal_map2, UV + offset2).rgb;
	NORMAL_MAP = mix(normal, normal2, 0.4);
	METALLIC = 0.;
	ROUGHNESS = 0.2;
	ALBEDO = albedo;
}