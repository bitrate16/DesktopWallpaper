#version 330 core

uniform float iTime;
uniform vec3 iResolution;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

float r(float n)
{
 	return fract(abs(sin(n*55.753)*367.34));   
}
float r(vec2 n)
{
    return r(dot(n,vec2(2.46,-1.21)));
}
float cycle(float n)
{
 	return cos(fract(n)*2.0*3.141592653)*0.5+0.5;
}
void main()
{
    float a = (radians(60.0));
    float zoom = 96.0;
	vec2 c = (fragCoord.xy+vec2(iTime*zoom,0.0))*vec2(sin(a),1.0);
    c = ((c+vec2(c.y,0.0)*cos(a))/zoom)+vec2(floor(4.*(c.x-c.y*cos(a))/zoom),0.0);
    float n = cycle(r(floor(c*4.0))*0.2+r(floor(c*2.0))*0.3+r(floor(c))*0.5+iTime*0.125);
	fragColor = vec4(0.0,n*2.0,pow(n,2.0),1.0);
}