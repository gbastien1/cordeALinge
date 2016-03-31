#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;

uniform mat3 normal_matrix;
uniform vec3 light_pos;
uniform vec3 cam_pos;

uniform float time;
uniform float angle;

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
const float h = 0.5;

const vec2 h1Direction = vec2(0.2,0.8);
const vec2 h2Direction = vec2(0.5,0.2);
const vec2 h3Direction = vec2(0.65,0.1);
const vec2 h4Direction = vec2(0.5,0.5);
const vec2 h5Direction = vec2(1,0.1);

float h1(float x, float y) {
    return exp(-0.5/y) * amplitude * sin((2*pi*frequence*y + 1) + (vitesse*time));
}

float h2(float x, float y) {
    return exp(-0.5/y) * 0.35 * amplitude * sin((2*pi*frequence*y * 1.1 * (x-1)) + (vitesse*time*1));
}

float h3(float x, float y) {
    return exp(-0.5/y) * 0.25 * amplitude * sin((2*pi*frequence*y * 0.5 * (x-1) ) + (vitesse*time*1));
}

float h4(float x, float y) {
    return exp(-0.5/y) * 0.1 * amplitude * sin((2*pi*frequence*y * 0.2 * (x-1) ) + (vitesse*time*1));
}

float h5(float x, float y) {
    return exp(-0.5/y) * 0.5 * amplitude * sin((2*pi*frequence*y * 0.35 * (x-1) ) + (vitesse*time*1));
}




float angley(float x, float y) {
    return y * angle * 0.012;
}

float anglez(float x, float y) {
    return y * angle * 0.075;
}


float f(float x, float y) {
    return  length(vec3(pos.x, pos.y, pos.z) +
                   vec3(0,
                   h1Direction.x * h1(x, y) + h2Direction.x * h2(x, y) + h3Direction.x * h3(x,y) + h4Direction.x * h4(x,y) + h5Direction.x * h5(x,y),
                   h1Direction.y * h1(x, y) + h2Direction.y * h2(x, y) + h3Direction.y * h3(x,y) + h4Direction.y * h4(x,y) + h5Direction.y * h5(x,y)));
    
}

vec3 sigma(float x, float y) {
    return vec3(x, y, f(x, y));
}


void main (void)
{
    var_texcoord = texcoord;

    float x = texcoord.x;
    float y = texcoord.y;
    
    // Main ondulation
    vec4 newPos = pos + vec4(0,
                             h1Direction.x * h1(x, y) + h2Direction.x * h2(x, y) + h3Direction.x * h3(x,y) + h4Direction.x * h4(x,y) + h5Direction.x * h5(x,y),
                             h1Direction.y * h1(x, y) + h2Direction.y * h2(x, y) + h3Direction.y * h3(x,y) + h4Direction.y * h4(x,y) + h5Direction.y * h5(x,y),
                             0);

    
    //Change Angle
    newPos +=           vec4(0,
                             angley(x, y),
                             anglez(x, y),
                             0);
    
    
    //calcul de normales
    vec3 dx = (sigma(x + h, y) - sigma(x, y)) / h;
    vec3 dy = (sigma(x, y + h) - sigma(x, y)) / h;
    N = normalize(cross(dx, dy));
    
    V = normalize(vec3(modelview_matrix*newPos));
    var_light_pos = normal_matrix*light_pos;
   
    
	gl_Position	= modelview_proj_matrix*newPos;
}


