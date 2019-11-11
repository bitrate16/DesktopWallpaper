#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

#define A_CH   0.25
#define B_CH   0.75
#define R_SC   4.0
#define PERIOD 2.0
#define PI     3.14159265358979323846
#define THICK  0.5
#define SPEED  16.0
#define RADMUL 24.8

float stroke(float radius, float angle) {
    return sin(radius * RADMUL - SPEED * iTime + angle * 2.0 * PI);
}

float polar(float radius, float angle) {
    if (radius < 1.0)
    	return sign(stroke(radius,  angle) - THICK);
    else if (radius < 2.0)
    	return sign(stroke(-radius, -angle) - THICK);
    else if (radius < 3.0)
    	return sign(stroke(radius,  angle) - THICK);
    else 
    	return sign(stroke(-radius, -angle) - THICK);
}

vec4 frag(float radius, float mradius, float angle) {
    float pol = polar(radius, angle);
    
    bool cond = abs(abs(pol) - radius) < 0.1;
    
    return vec4(pol); // vec4(cond ? 1.0 : 0.0);
}

void main() {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Constants
    float MAX_RADIUS = min(iResolution.x, iResolution.y) / R_SC;
    
    // Get radius
    vec2  radvec = fragCoord.xy - iResolution.xy / 2.0;
    float radius = length(radvec);
 	
    // Get rotation angle [0.0 - 1.0]
    float angle  = atan(radvec.y / radvec.x) / (3.14 * PERIOD) + 0.25;
    if(radvec.x <= 0.0)
        angle += 0.5;
    #ifdef MIRROR
    	if(radvec.x <= 0.0)
            angle = 1.0 - angle;
    #endif
    
    radius /= MAX_RADIUS;
    fragColor = frag(radius, MAX_RADIUS, angle);
}