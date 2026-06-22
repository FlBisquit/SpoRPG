shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 out_col : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float amount : hint_range(0.2, 1.5) = 0.8;
uniform float beer_factor = 0.2;
uniform float metallic_val = 0.7;
uniform float roughness_val = 0.3;
uniform float specular_val = 0.5;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

float gen_offset(float x, float z, float val1, float val2, float time) {
    float spd = 1.0;
    float radX = ((mod(x + z * x * val1, amount) / amount)
                  + (time * spd) * mod(x * 0.8 + z, 1.5)) * 2.0 * PI;
    float radZ = ((mod(val2 * (z * x + x * z), amount) / amount)
                  + (time * spd) * 2.0 * mod(x, 2.0)) * 2.0 * PI;
    return amount * 0.5 * (sin(radZ) + cos(radX));
}

vec3 apply_dist(vec3 vertex, float time) {
    float xd = gen_offset(vertex.x, vertex.z, 0.2, 0.1, time);
    float yd = gen_offset(vertex.x, vertex.z, 0.1, 0.3, time);
    float zd = gen_offset(vertex.x, vertex.z, 0.15, 0.2, time);
    return vertex + vec3(xd, yd, zd);
}

void vertex() {
    VERTEX = apply_dist(VERTEX, TIME * 0.1);
}

void fragment() {
    ALBEDO = vec3(0.0, 0.5, 1.0);
    ALPHA = 1.0; 
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
    METALLIC = metallic_val;
    SPECULAR = specular_val;
    ROUGHNESS = roughness_val;

   
}