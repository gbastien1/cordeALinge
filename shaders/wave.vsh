#version 410

uniform mat4 modelview_proj_matrix;
uniform mat4 modelview_matrix;

uniform mat3 normal_matrix;
uniform vec3 light_pos;
uniform vec3 cam_pos;

//AL received time and rotation angle from CPU
uniform float time;
uniform float angle;

//AL harmonics default parameters
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

//AL directional vectors of harmonics
const vec2 h1Direction = vec2(0.2,0.8);
const vec2 h2Direction = vec2(0.5,0.2);
const vec2 h3Direction = vec2(0.65,0.1);
const vec2 h4Direction = vec2(0.5,0.5);
const vec2 h5Direction = vec2(1,0.1);

/**
 * AL Definition of harmonic functions
 */
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


//GB AL harmonics functions altogether
vec4 getHarmonics(float x, float y) {
    return vec4(0,
                h1Direction.x * h1(x, y) + h2Direction.x * h2(x, y) + h3Direction.x * h3(x,y) + h4Direction.x * h4(x,y) + h5Direction.x * h5(x,y),
                h1Direction.y * h1(x, y) + h2Direction.y * h2(x, y) + h3Direction.y * h3(x,y) + h4Direction.y * h4(x,y) + h5Direction.y * h5(x,y),
                0);
}


// AL definition of sheet rotation functions
float angley(float x, float y) {
    return y * angle * 0.012;
}
float anglez(float x, float y) {
    return y * angle * 0.075;
}


//GB harmonic function used to calculate partial derivatives of surface
float f(float x, float y) {
    return  length(pos + getHarmonics(x, y));
    
}

//GB definition of general surface function
vec3 sigma(float x, float y) {
    return vec3(x, y, f(x, y));
}


void main (void)
{
    var_texcoord = texcoord;

    float x = texcoord.x;
    float y = texcoord.y;
    
    // AL Main ondulation
    vec4 newPos = pos + getHarmonics(x, y);

    
    //AL Change angle
    newPos += vec4(0,
                   angley(x, y),
                   anglez(x, y),
                   0);
    
    
    //GB derivatives used to calculate normals
    vec3 dx = (sigma(x + h, y) - sigma(x, y)) / h;
    vec3 dy = (sigma(x, y + h) - sigma(x, y)) / h;
    N = normalize(cross(dx, dy));
    
    V = normalize(vec3(modelview_matrix*newPos));
    var_light_pos = normal_matrix*light_pos;
   
    
	gl_Position	= modelview_proj_matrix*newPos;
}


