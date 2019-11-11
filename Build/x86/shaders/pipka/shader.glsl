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
    c.r = 0.3 * sin(dist * 2.0 * PI * 40.0 + iTime * 2.0 * PI * 2.0);
    c.g = 0.7 * sin(dist * 2.0 * PI * 80.0 + iTime * 2.0 * PI * 2.0);
    c.b = 0.3 * sin(dist * 2.0 * PI * 120.0 + iTime * 2.0 * PI * 2.0);
    
    return c;
}

void main() {
    vec2 uv = (fragCoord - iResolution.xy / 2.0) * 1.5 / max(iResolution.x, iResolution.y);
	
    float d0 = segment_check(uv, vec2(-0.1, 0.2), vec2(0.1,  0.0), 10.0);
    float d1 = segment_check(uv, vec2(-0.2, 0.1), vec2(0.0, -0.1), 10.0);
    
    // -5.0 * PI4, 0.0
    // -PI2, 3.0 * PI4
    float d2 = abs(circle_check(uv, vec2(0.1 * sqrt(2.0) / 2.0 + 0.1, -0.1 * sqrt(2.0) / 2.0), 0.1, 0.0, 2.0 * PI, 10.0)); 
    float d3 = abs(circle_check(uv, vec2(0.1 * sqrt(2.0) / 2.0, -0.1 * sqrt(2.0) / 2.0 - 0.1), 0.1, 0.0, 2.0 * PI, 10.0));
    
    float d4 = abs(circle_check(uv, vec2(-0.15, 0.15), 0.1 * sqrt(2.0) / 2.0, 1.0 * PI4, 5.0 * PI4, 10.0));
    
    float mn = min(d0, d1);
          mn = min(mn, d2);
          mn = min(mn, d3);
          mn = min(mn, d4);
    
    mn = 1.0 - mn;
    
    fragColor = color(mn);
    // fragColor.r = cos(mn * 100.0 + 0.5 * iTime);
    // fragColor.g = cos(mn * 100.0 + 1.0 * iTime);
    // fragColor.b = cos(mn * 100.0 + 2.0 * iTime);
    // fragColor.a = 1.0;
}