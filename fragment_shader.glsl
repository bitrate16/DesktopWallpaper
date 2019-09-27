#version 330 core

// Usable header to adopt shader to shadertoy
uniform float iTime;
uniform float iTimeDelta;
uniform int iFrame;
uniform vec3 iResolution;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

// Shader source goes here...

void main() {
    vec2 uv = fragCoord / iResolution.xy;

    vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));

    fragColor = vec4(col, 1.0);
}