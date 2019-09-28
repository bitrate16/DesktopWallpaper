#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

float noise(vec2 p) {
    return fract(dot(sin(p.x * 123.12)*142.,cos(p.y *34.95)*165.47));
}

void main() {
	vec2 uv = fragCoord.xy / iResolution.xy ;
    float n = noise(uv + iTime);
	fragColor = vec4(n,n,n,1.0);
}