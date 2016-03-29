#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;

uniform mat3 normal_matrix;
uniform vec3 light_pos;
uniform vec3 cam_pos;

in vec4     pos;
in vec2     texcoord;
in vec3     N0;

out vec2 var_texcoord;

out vec3 N;
out vec3 V;
out vec3 var_light_pos;


void main (void)
{
    var_texcoord = texcoord;
    
    N = normalize(normal_matrix*N0);
    V = normalize(vec3(modelview_matrix*pos));
    var_light_pos = normal_matrix*light_pos;
    
	gl_Position	= modelview_proj_matrix*pos;
}


