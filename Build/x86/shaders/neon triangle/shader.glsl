#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

#define PI  3.14159265359
#define PI0 6.28318530718
#define PI2 1.57079632679
#define PI4 0.78539816339

// SQRT
float circle(vec2 v, vec2 center, float radius) {
    return distance(v, center) - radius;
}

// Segment from A to B as segment
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

// Distance to color function
vec4 color(float dist) {
	vec4 c;
	c.a = 1.0;
	
    // Neon
	c.r = c.g = c.b = 1. / pow(2.0 + 0.5 * sin(iTime * 2.0), dist * 100.);
    c.g *= 1.0;
    c.r *= 0.3;
    c.b *= 0.7;
	
    return c;
}

float triangle(vec2 uv, vec2 A, vec2 B, vec2 C, float far) {
    float mn = far;
    mn = min(mn, segment_check(uv, A, B, 10.0));
    mn = min(mn, segment_check(uv, B, C, 10.0));
    mn = min(mn, segment_check(uv, C, A, 10.0));
    mn = min(mn, circle(uv, A, 0.0));
    mn = min(mn, circle(uv, B, 0.0));
    mn = min(mn, circle(uv, C, 0.0));
    return mn;
}

// DISPLAY
void main() {
    vec2 uv = (fragCoord - iResolution.xy / 2.0) / max(iResolution.x, iResolution.y);
    
    vec2 A = 0.1 * vec2(cos(1.0 * PI / 3.0 + iTime), sin(1.0 * PI / 3.0 + iTime));
    vec2 B = 0.1 * vec2(cos(3.0 * PI / 3.0 + iTime), sin(3.0 * PI / 3.0 + iTime));
    vec2 C = 0.1 * vec2(cos(5.0 * PI / 3.0 + iTime), sin(5.0 * PI / 3.0 + iTime));
    
    float mn = 10.0;
    
    mn = min(mn, triangle(uv, A, B, C, 10.0));
    
    fragColor = color(mn);
}