#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

vec3 hsv(float h,float s,float v) {
	return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}
float circle(vec2 p, float r) {
	return smoothstep(0.1, 0.0, abs(length(p)-r)); // try changing the 0.1 to 0.3
}
float r3 = sqrt(3.0);
void main() {
	vec2 uv = -1.0 + 2.0*fragCoord.xy / iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
	uv *= 10.0;
	float r = smoothstep(-0.7, 0.7, sin(iTime*1.57-length(uv)*0.1))+1.0;
	vec2 rep = vec2(4.0,r3*4.0);
	vec2 p1 = mod(uv, rep)-rep*0.5;
	vec2 p2 = mod(uv+vec2(2.0,0.0), rep)-rep*0.5;
	vec2 p3 = mod(uv+vec2(1.0,r3), rep)-rep*0.5;
	vec2 p4 = mod(uv+vec2(3.0,r3), rep)-rep*0.5;
	vec2 p5 = mod(uv+vec2(0.0,r3*2.0), rep)-rep*0.5;
	vec2 p6 = mod(uv+vec2(2.0,r3*2.0), rep)-rep*0.5;
	vec2 p7 = mod(uv+vec2(1.0,r3*3.0), rep)-rep*0.5;
	vec2 p8 = mod(uv+vec2(3.0,r3*3.0), rep)-rep*0.5;
	
	float c = 0.0;
	c += circle(p1, r);
	c += circle(p2, r);
	c += circle(p3, r);
	c += circle(p4, r);
	c += circle(p5, r);
	c += circle(p6, r);
	c += circle(p7, r);
	c += circle(p8 , r);
	fragColor = vec4(hsv(r+0.7, 1.0, c), 1.0);
}