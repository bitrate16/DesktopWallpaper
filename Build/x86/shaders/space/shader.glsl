#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

void main() {
	float t = iTime * 0.01;
	float a = iResolution.x / iResolution.y;
	float x = iMouse.x;
	float y = iMouse.y;
	vec3 f=vec3(fragCoord.rg/640.-.5,1.);
	f.g*=a;
	float c=.5+x/500.,v=.5+y/500.;
	mat2 m=mat2(cos(c),sin(c),-sin(c),cos(c)),s=mat2(cos(v),sin(v),-sin(v),cos(v));
	f.rb*=m;
	f.rg*=s;
	vec3 r=vec3(1.,.5,.5);
	r+=vec3(t*2.,t,-2.);
	r.rb*=m;
	r.rg*=s;
	float g=.1,b=1.;
	vec3 i=vec3(0.);
	for(int l=0;l<20;l++) {
		vec3 o=r+g*f*.5;
		o=abs(vec3(1.)-mod(o,vec3(2.)));
		float e,n=e=0.;
		for(int d=0;d<20;d++)
			o=abs(o)/dot(o,o)-.53,n+=abs(length(o)-e),e=length(o);
		if(l>6)
			b*=1.-max(0.,.3-n*n*.001);
		i+=b+vec3(g,g*g,g*g*g*g)*n*n*n*.0015*b;
		b*=.73;
		g+=.1;
	}
	i=mix(vec3(length(i)),i,.85);
	fragColor=vec4(i*.01,1.);
}