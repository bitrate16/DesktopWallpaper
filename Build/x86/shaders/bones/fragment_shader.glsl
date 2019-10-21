#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
vec2 fragCoord = gl_FragCoord.xy;

out vec4 fragColor;

#define PI  3.14159265359
#define PI0 6.28318530718
#define PI2 1.57079632679
#define PI4 0.78539816339

// #define FAST
#define ROTATION
#define SCALE 6.0

// SQRT
float circle(vec2 v, vec2 center, float radius) {
    return distance(v, center) - radius;
}

float circle_check(vec2 v, vec2 center, float radius, float a, float b, float far) {
    vec2 dir = v - center;
    float angle = PI + atan(dir.x, dir.y);
    
    if (a < 0.0) {
        if (b < 0.0) {
            if (angle < a + 2.0 * PI || angle > b + 2.0 * PI)
                return far;
        } else {
            if (angle < a + 2.0 * PI && angle > b)
                return far;
        }
    } else if (angle < a || angle > b)
        return far;
    
    return length(dir) - radius;
}

float segment(vec2 v, vec2 A, vec2 B) {
    vec2 n  = B - A;
    vec2 va = A - v;
    vec2 c  = n * dot(va, n) / dot(n, n);
    return length(va - c);
}

float segment_check(vec2 v, vec2 A, vec2 B, float far) {
    vec2 b = B - A;
    vec2 a = v - A;
    float frac = dot(a, b) / dot(b, b);
    if (frac < 0.0 || frac > 1.0)
        return far;
    
    vec2 n  = B - A;
    vec2 va = A - v;
    vec2 c  = n * dot(va, n) / dot(n, n);
    return length(va - c);
}

float round_segment_check(vec2 v, vec2 A, vec2 B, float far) {
    vec2 b = B - A;
    vec2 a = v - A;
    float frac = dot(a, b) / dot(b, b);
    if (frac < 0.0)
        return distance(v, A);
    if (frac > 1.0)
        return distance(v, B);
    
    vec2 n  = B - A;
    vec2 va = A - v;
    vec2 c  = n * dot(va, n) / dot(n, n);
    return length(va - c);
}

vec4 color(float dist) {
   vec4 c;
    c.a = 1.0;
    c.r = c.g = c.b = 1. / pow(2.0 + 0.2 * sin(mod(iTime, PI) * 4.0), dist * 60.);
    c.r *= 0.462745098;
    c.g *= 0.939215686;
    c.b *= 0.403921569;
    
    return c;
}

void main() {    
    fragCoord.xy = SCALE * fragCoord.xy + vec2(iTime * 500., iTime * 1000.);
    vec2 quarantOffset = round((fragCoord.xy - 0.5 * iResolution.xy) / iResolution.xy);
    
    fragCoord += cos(quarantOffset.yx * PI + mod(iTime, PI) * 4.) * iResolution.yx * 0.04;
    fragCoord.xy = mod(fragCoord.xy, iResolution.xy);
    
    vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / max(iResolution.x, iResolution.y);
    
    // Scale to fit light
    uv *= 1.5;
    uv.y -= 0.017;
    
    bool qX = (int(quarantOffset.x) & 1) == 0;
    bool qY = (int(quarantOffset.y) & 1) == 0;
    
    // Invert coords
    if (qX) 
        uv.y = -uv.y;
    
    if (qY) 
        uv.x = -uv.x;

#ifdef ROTATION
    // Rotation
    float s = cos((qX && qY ? 1.0 : -1.0) * mod(iTime, PI) * 4.);
    float c = sin((qX && qY ? 1.0 : -1.0) * mod(iTime, PI) * 4.);
    mat2 m = mat2(c, -s, s, c);
    uv = m * uv;
#endif

#ifdef FAST
    float d0 = round_segment_check(uv, vec2(0.0, 0.1), vec2(0.1,  0.0), 10.0);
    float d1 = round_segment_check(uv, vec2(-0.1, 0.0), vec2(0.0, -0.1), 10.0);
	
    float d2 = abs(circle(uv, vec2(0.1 * sqrt(2.0) / 2.0 + 0.1, -0.1 * sqrt(2.0) / 2.0), 0.1)); 
    float d3 = abs(circle(uv, vec2(0.1 * sqrt(2.0) / 2.0, -0.1 * sqrt(2.0) / 2.0 - 0.1), 0.1));
    
    float d22 = abs(circle(uv, -vec2(0.1 * sqrt(2.0) / 2.0 + 0.1, -0.1 * sqrt(2.0) / 2.0), 0.1)); 
    float d32 = abs(circle(uv, -vec2(0.1 * sqrt(2.0) / 2.0, -0.1 * sqrt(2.0) / 2.0 - 0.1), 0.1));
#else
    float d0 = round_segment_check(uv, vec2(0.0, 0.1), vec2(0.1,  0.0), 10.0);
    float d1 = round_segment_check(uv, vec2(-0.1, 0.0), vec2(0.0, -0.1), 10.0);
    
    float d2 = abs(circle_check(uv, vec2(0.1 * sqrt(2.0) / 2.0 + 0.1, -0.1 * sqrt(2.0) / 2.0), 0.1, -5.0 * PI4, 0.0, 10.0)); 
    float d3 = abs(circle_check(uv, vec2(0.1 * sqrt(2.0) / 2.0, -0.1 * sqrt(2.0) / 2.0 - 0.1), 0.1, -PI2, 3.0 * PI4, 10.0));
    float d23 = abs(circle(uv, vec2(0.1 + 0.1 * sqrt(2.0) / 2.0, -0.1 - 0.1 * sqrt(2.0) / 2.0), 0.0));
    
    float d22 = abs(circle_check(uv, -vec2(0.1 * sqrt(2.0) / 2.0 + 0.1, -0.1 * sqrt(2.0) / 2.0), 0.1, -PI4, PI, 10.0)); 
    float d32 = abs(circle_check(uv, -vec2(0.1 * sqrt(2.0) / 2.0, -0.1 * sqrt(2.0) / 2.0 - 0.1), 0.1, PI2, 7.0 * PI4, 10.0));
    float d232 = abs(circle(uv, -vec2(0.1 + 0.1 * sqrt(2.0) / 2.0, -0.1 - 0.1 * sqrt(2.0) / 2.0), 0.0));
#endif
    
    //float d5 = segment_check(uv, vec2(-0.5, -0.28), vec2( 0.5, -0.28), 10.0);
    //float d6 = segment_check(uv, vec2( 0.5, -0.28), vec2( 0.5,  0.28), 10.0);
    //float d7 = segment_check(uv, vec2( 0.5,  0.28), vec2(-0.5,  0.28), 10.0);
    //float d8 = segment_check(uv, vec2(-0.5,  0.28), vec2(-0.5, -0.28), 10.0);
    
    float mn = min(d0, d1);
          mn = min(mn, d2);
          mn = min(mn, d3);
          mn = min(mn, d22);
          mn = min(mn, d32);
#ifndef FAST
          mn = min(mn, d23);
          mn = min(mn, d232);
#endif
		  
    //      mn = min(mn, d5);
    //      mn = min(mn, d6);
    //      mn = min(mn, d7);
    //      mn = min(mn, d8);
    
    fragColor = color(mn);
}