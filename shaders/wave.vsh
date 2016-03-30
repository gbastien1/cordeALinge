#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;

uniform mat3 normal_matrix;
uniform vec3 light_pos;
uniform vec3 cam_pos;

uniform float time;

uniform float amplitude = 0.8;
uniform float frequence = 2;
uniform float vitesse = 4;


in vec4     pos;
in vec2     texcoord;
in vec3     N0;

out vec2 var_texcoord;

out vec3 N;
out vec3 V;
out vec3 var_light_pos;

const float pi = 3.14159265359;

void main (void)
{
    var_texcoord = texcoord;
    
    vec4 newPos = pos + vec4(0,
                             0,
                             exp(-0.01/texcoord.y) * amplitude * sin((2*pi*frequence*texcoord.y + 1) + (vitesse*time)),
                             0);
    
    newPos +=           vec4(0,
                             exp(-0.01/texcoord.y) * 0.2 * amplitude * sin((2*pi*frequence*texcoord.y * (texcoord.x-1)) + (vitesse*time)),
                             0,
                             0);
    
    
    N = normalize(normal_matrix*N0);
    V = normalize(vec3(modelview_matrix*newPos));
    var_light_pos = normal_matrix*light_pos;
    
 
    
    
	gl_Position	= modelview_proj_matrix*newPos;
}


