#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

// [SH17B] Adventure Time
// by Michal "spolsh" Klos 2017
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define BLACK vec3(0.0)
#define WHITE vec3(1.0)
#define BG vec3(249.0/255.0, 192.0/255.0, 41.0/255.0)
#define MOUNTH0 vec3(0.5, 0.0, 0.2)
#define MOUNTH1 vec3(0.9, 0.4, 0.4)
#define DBG vec3(1.0, 0.0, 1.0)
#define STROKE 0.005

#define RES iResolution
#define FRAG fragCoord
#define T (40.0*iTime)
#define t (2.0*iTime)
#define M (iMouse.xy)

float udBox( vec2 p, vec2 b )
{ // by iq
  return length(max(abs(p)-b,0.0));
}

float sdCapsule( vec2 p, vec2 a, vec2 b, float r )
{ // by iq
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

void main()
{
	vec2 uv = FRAG/RES.xy-0.5;
    uv.y *= RES.y/RES.x; 
    //uv *= vec2(1.5);
    uv += 0.01*vec2(cos(t),sin(t));
    uv.y += 0.05;
        
    float irisMove = 0.002*sin(T);
    vec2 facePos	= vec2(0.0, 0.15);
    vec2 eyePos0	= facePos +vec2( 0.14, 0.0);
    vec2 eyePos1	= facePos +vec2(-0.14, 0.0);
    vec2 irisPos0	= eyePos0 +vec2(0.017 +irisMove, 0.025);
    vec2 irisPos1	= eyePos1 +vec2(0.017 +irisMove, 0.025);
    vec2 irisPos2	= eyePos0 +vec2(-0.04 +irisMove, -0.052);
    vec2 irisPos3	= eyePos1 +vec2(-0.04 +irisMove, -0.052);    
    vec2 nosePos	= facePos +vec2(0.0, -0.05);
    vec2 moustachePos0	= facePos +vec2(0.0, -0.05);
    vec2 moustachePos1	= facePos +vec2(0.0, -0.20);    
    vec2 handsPos = vec2(0.0, -0.2) + vec2(0.0, 0.01*sin(t));
    vec2 lidPos	= vec2(0.0, -0.09);
    
    vec2 mouseDir = normalize(((fragCoord.xy-M)/RES.xy) - facePos);
       
    vec2 p0 = uv;
    p0.y *= 1.6;
    
    float s0 = length(uv -eyePos0)	 - 0.1;
    float s1 = length(uv -eyePos1)	 - 0.1;
    float s2  = length(uv -irisPos0 +0.008*mouseDir)  - 0.065;
    float s3  = length(uv -irisPos1 +0.008*mouseDir)  - 0.065;    
    float s9  = length(uv -irisPos2 +0.008*mouseDir)  - 0.025;
    float s10 = length(uv -irisPos3 +0.008*mouseDir) - 0.025;
    float s4 = length(p0 -nosePos - vec2(0.0, 0.015)) - 0.062;
    float s5 = length(p0 -moustachePos0) - 0.12;
    float s6 = length(p0 -moustachePos0) - 0.12-STROKE;
    float s7 = uv.y-0.06;
    float s11 = sdCapsule(p0, nosePos +vec2( 0.091, -0.098), nosePos +vec2( 0.091, 0.0), 0.034);
    float s12 = sdCapsule(p0, nosePos +vec2(-0.091, -0.098), nosePos +vec2(-0.091, 0.0), 0.034);
    float s13 = min(max(-s7, s6), min(s11, s12));
    float s14 = s13 +STROKE;    
        
    vec2 p1 = uv -facePos -handsPos;
    p1.x = -abs(p1.x) + 0.15;    
    float s15 = sdCapsule(p1, vec2(0.0,    0.0), vec2(0.0,    -1.8), 0.02);
    float s16 = sdCapsule(p1, vec2(-0.037, 0.0), vec2(-0.037, -1.8), 0.02);
    float s17 = sdCapsule(p1, vec2(-0.074, 0.0), vec2(-0.074, -1.8), 0.02);
    float s18 = udBox(p1      +vec2(0.04, 0.3), vec2(0.04, 0.28));
    float s19 = min(s15, min(s16, s17));
    float s20 = min(s18, s19 +STROKE);
    
    vec2 p2 = uv -facePos -lidPos; 
    p2.x = -abs(p2.x) + 0.15;        
    p2 *= vec2(1.0, 2.0);
    float s21 = length(p2) -0.09;
    float s22 = length(p2 +vec2(0.001, 0.015)) -0.09;
        
    vec2 p3 = uv * vec2(1.0, 1.05);
    p3.y += 0.001*sin(t);
    float s23 = length(p3 -facePos -vec2(0.0, -0.085)) - 0.065;
    float s24 = s23 +STROKE;        
    float s26 = length(p3 -facePos -vec2( 0.0,  -0.115)) - 0.017;
    float s27 = length(p3 -facePos -vec2( 0.03, -0.108)) - 0.017;
    float s28 = length(p3 -facePos -vec2(-0.03, -0.108)) - 0.017;
    float s29 = min( s28, min(s26, s27));
    float s30 = min( s28, min(s26, s27)) +0.004;
    p3.y += 0.002*sin(t);
    float s25 = max( length(p3 -facePos +0.008*mouseDir -vec2(0.02, -0.16)) - 0.03, s24);
    
    vec3 c = BG;    
    c = mix(BLACK,   c, smoothstep(0.0, 0.002, min( s0, s1 )));
    c = mix(WHITE,   c, smoothstep(0.0, 0.002, min( min( s9, s10), min(s2, s3))));
    c = mix(BLACK,   c, smoothstep(0.0, 0.002, min(s21, s23)));
    c = mix(MOUNTH0, c, smoothstep(0.0, 0.002, s24));        
    c = mix(MOUNTH1, c, smoothstep(0.0, 0.002, s25));                 	
    c = mix(BLACK,   c, smoothstep(0.0, 0.002, s29));
    c = mix(WHITE,   c, smoothstep(0.0, 0.002, s30));
    c = mix(BG,      c, smoothstep(0.0, 0.002, s22));     
    c = mix(BLACK,   c, smoothstep(0.0, 0.002, s13));
    c = mix(BG,      c, smoothstep(0.0, 0.002, s14));   
    c = mix(BLACK,   c, smoothstep(0.0, 0.002, min(s4, s19)));    
    c = mix(BG,      c, smoothstep(0.0, 0.002, s20));                 	       
    
    // c = mix(DBG,     c, smoothstep(0.0, 0.002, length((fragCoord.xy-M)/RES.xy) - 0.017));                 	       
           
	fragColor = vec4(c, 0.0);    
}