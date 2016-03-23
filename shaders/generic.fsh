#version 410
in vec2     var_texcoord;
out vec4    frag_color;

uniform mat3 normal_matrix;

uniform sampler2D tex_diffuse;
uniform sampler2D tex_bumpmap;


uniform float diffuse_contrib;
uniform float ambiant_contrib;
uniform float spec_contrib;
uniform float mat_shininess;
uniform float mirror_factor;

vec4 mat_spec_color = vec4(0.9, 0.9, 0.9, 1.0);
vec4 mat_ambient_color = vec4(0.2, 0.2, 0.2, 1.0);

in vec3 var_light_pos;

in vec3 N;
in vec3 V;

in vec3 cam_eye;

void main (void)
{

    vec4 diffuse_color;
    vec4 specular_color;
    vec3 N2;
    
    vec2 q = var_texcoord.st;
        
    N2 = normalize(N);
    vec3 L = normalize(var_light_pos - V);
    vec3 E = normalize(-V);
    vec3 Rl = normalize(reflect(-L, N2));
    
    vec4 tcolor = texture(tex_diffuse, q);
    diffuse_color = clamp(tcolor*max(dot(N2, L), 0.0), 0.0, 1.0);
    
   	specular_color = clamp(mat_spec_color*pow(max(dot(Rl, E), 0.0), mat_shininess), 0.0, 1.0);
    
    frag_color = ambiant_contrib*mat_ambient_color + diffuse_contrib*diffuse_color + spec_contrib*specular_color;
     
}
