#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

float easingSinInOut(float t){
   t = mod(t,1.0);
   return 0.5*(1.0 - cos(3.14159 * t)); 
}

float triDist(vec2 p){
  float f = smoothstep(0.0,0.01,p.x-p.y);
  f*=  smoothstep(0.0,0.01,-p.x-p.y);
  f*=  smoothstep(0.0,0.01,0.5+p.y);
  return f;
}
 
void main() {
  vec2 p = fragCoord.xy/iResolution.xy;
  p-=0.5;
  p.x *= iResolution.x/iResolution.y;
  p*=15.0;
  
  float t = mod(0.7*iTime,4.0);
  p.x+=6.0*easingSinInOut(t)*(1.0-step(1.0,t));
  p.x+=6.0*step(1.0,t)*(1.0-step(2.0,t));
  p.x+=(6.0-6.0*easingSinInOut(t))*step(2.0,t)*(1.0-step(3.0,t));
  p.x+=0.0*step(3.0,t)*(1.0-step(4.0,t));

  p.y+=0.0*(1.0-step(1.0,t));  
  p.y+=6.0*easingSinInOut(t)*step(1.0,t)*(1.0-step(2.0,t));
  p.y+=6.0*step(2.0,t)*(1.0-step(3.0,t));
  p.y+=(6.0-6.0*easingSinInOut(t))*step(3.0,t)*(1.0-step(4.0,t));
  
  float gridsize = 1.3;
 
  vec2 pcenter = floor((p)/gridsize);
 
  float angle = 1.0+iTime+10.0*sin(1.0*pcenter.y+1.0*iTime)*sin(1.0*pcenter.x+1.0*iTime);
  angle = angle;
 
  vec2 prot=mod(p,gridsize)-gridsize/2.0;
  prot  = mat2(
    cos(angle),
    sin(angle),
    -sin(angle),
    cos(angle)
  )*prot;
 
  vec2 ptrans = prot-vec2(0.0,0.0);
  float f = triDist(ptrans);
 
  ptrans = mat2(
    cos(3.14159/1.0),
    sin(3.14159/1.0),
    -sin(3.14159/1.0),
    cos(3.14159/1.0)
  )*prot;
  ptrans = ptrans-vec2(0.0,-0.0);
 
  f = max(f,triDist(ptrans));
 
  float m = 0.5+0.5*sin(123.0*pcenter.x+5587.0*pcenter.y+3.0*iTime);
  fragColor = vec4(m*f,0.0,0.0,1.0);
}