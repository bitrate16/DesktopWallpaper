#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

void main(){
	float T = 21.0 + iTime * 0.001;
	float X = (iMouse.x + iMouse.y) * 0.25 + iResolution.x * 0.4 + iResolution.y * 0.4;
    float sine = sin(T);
    float fracte = fract(sine);
    float x = .001;
	vec4 v;
    float z = 669. * fracte;
    float m = v.z += X * x / fracte;

    vec3 point = vec3(fragCoord.xy / z - fracte, T);
    vec3 o = point.xzy * sine;
    vec3 c;

    x = o.x;
    z = o.z;
    o.xz = vec2(x * fracte - m * z, m * x + z) * sine;

    z = 0.;
    for(int i = 0; i < 32; ++i) {
        point = vec3(-2.12, 1.778, -3.4204) + z * o;
        for(int i = 0; i < 33; ++i) {
            x = dot(point, point);
            v += vec4(point = abs(point) / x, point -= vec3(.5, .4, 1.5));
        };
        v /= 32.;
        z += max(.001 * m * fracte, min(.01 / m, x = 1. - abs(1. - x))) * (.3 + 3. * z);
        c += (.3 + .7 * sin(v.xyz * 30.)) / (1. + x * x * 1E3);
    };

    fragColor += vec4(.001 + pow(c / 5., vec3(.669)), v * fracte);
}