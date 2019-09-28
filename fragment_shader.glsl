#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

//////////////////////////////////////////////////////////////////////////////////
// Infinite Yin Yang Zoom - Copyright 2017 Frank Force
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//////////////////////////////////////////////////////////////////////////////////

const float zoomSpeed			= -0.4;	// how fast to zoom (negative to zoom out)
const float zoomScale			= 0.08;	// how much to multiply overall zoom (closer to zero zooms in)
const float saturation			= 0.4;	// how much to scale saturation (0 == black and white)
const float turnSpeed			= 0.7;	// how fast to rotate (0 = no rotation)
const int   recursionCount		= 10;	// how deep to recurse
const float dotSize 			= 0.6;	// how much to scale recursion at each step
const float blur				= 5.0;	// how much blur
const float outline				= 0.12;	// how thick is the outline
const float timeWarp			= 1.0;	// time warp to add curvature

//////////////////////////////////////////////////////////////////////////////////
    
const float pi = 3.14159265359;
const float e = 2.718281828459;
float RandFloat(int i) { return (fract(sin(float(i)) * 43758.5453)); }
vec2 Rotate(vec2 p, float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return vec2((p.x*c - p.y*s), (p.x*s + p.y*c));
}
vec4 HsvToRgb(vec4 c) 
{
    float s = c.y * c.z;
    float s_n = c.z - s * .5;
    return vec4(s_n) + vec4(s) * cos(2.0 * pi * (c.x + vec4(1.0, 0.6666, .3333, 1.0)));
}

float GetFocusRotation(int i) 
{ 
    float theta = 2.0*pi*RandFloat(i);
    float s = mix(-1.0, 1.0, RandFloat(30+i));
    //s += ((s < 0.0)? -.5 : 0.5);
    return theta + turnSpeed*s*iTime; 
}

vec2 GetFocusPos(int i) 
{ 
    bool side = (RandFloat(50+i) < 0.5);
    vec2 p = vec2(0.0, side? -0.5 : 0.5); 
    return Rotate(p, GetFocusRotation(i));
}

//////////////////////////////////////////////////////////////////////////////////

float YinYang2( vec2 p, out float dotDistance, float co, float scale)
{
   	float b = blur*scale/min(iResolution.y, iResolution.x);
    float d = dotSize;
    
    float c = 1.0;
    float r;
    
    // bottom
    r = length(2.0*p + vec2(0, 1));
    if (p.x < 0.0)
	   c = mix(c, 0.0, smoothstep(1.0-b, 1.0+b, r));
    dotDistance = r;
    
    // top
    r = length(2.0*p - vec2(0, 1));
    if (p.x >= 0.0)
		c = mix(0.0, c, smoothstep(1.0-b, 1.0+b, r));
    if (p.y >= 0.0)
         dotDistance = r;
    
    // outline
    r = length(p);
    c = mix(c, co, smoothstep(1.0-b, 1.0, r));
    
    return c;
}

vec4 RecursiveYinYang(vec2 p, int iterations, float scale)
{
    // recursive iteration
    float co = 0.0;
    for (int r = 0; r < recursionCount; ++r)
    {
        // apply rotation
  		float theta = -GetFocusRotation(iterations + r);
        p = Rotate(p, theta);
        
        float dotDistance = 0.0;
        co = YinYang2(p, dotDistance, co, scale);
        
        if (dotDistance > dotSize || r == recursionCount)
        {
            float co2 = (p.y < 0.0)? 0.0 : 1.0;
   			float b = blur*scale/min(iResolution.y,iResolution.x);
            
            co = mix(co2, co, smoothstep(dotSize+outline,dotSize+outline+b,dotDistance));
            int i2 = (dotDistance < dotSize+outline+b && p.y > 0.0)? 1 : 0;
            float hue = 0.233*float(iterations + r + i2);
            return vec4(hue, saturation*co, co, 1.0); // stop if outside or reached limit
        }
     	
		// check if top or bottom
        co = (p.y > 0.0)? 1.0 : 0.0;
        p.y += mix(0.5, -0.5, co);
        
        scale *= 2.0/dotSize;
        p *= 2.0/dotSize;		// apply recursion scale
        p = Rotate(p, -theta);	// cancel out rotation
    }
    return vec4(0);
}

//////////////////////////////////////////////////////////////////////////////////

void main()
{
    // fixed aspect ratio
	vec2 p = (2.0*fragCoord-iResolution.xy)/min(iResolution.y,iResolution.x);
    vec2 p2 = p;
    
    // wander center
	p.x += 0.5*sin(0.234*iTime);
	p.y += 0.5*sin(0.2*iTime);
    
    // time warp
    float time = iTime + timeWarp*length(p);
    
	// get time 
	float timePercent = time*zoomSpeed;
	int iterations = int(floor(timePercent));
	timePercent -= float(iterations);
    
	// update zoom, apply pow to make rate constant
    const float recursionSize = 2.0 / dotSize;
	float zoom = pow(e, -log(recursionSize)*timePercent);
	zoom *= zoomScale;
    
	// get focus offset
	vec2 offset = GetFocusPos(iterations);
	for (int i = 0; i < 10; ++i)
		offset += (GetFocusPos(iterations+i+1) / recursionSize) * pow(1.0 / recursionSize, float(i));
    
    // apply zoom and offset
	p = p*zoom + offset;
    
    // make the yin yang
    fragColor = RecursiveYinYang(p, iterations, zoom);
    
    // wander hue
    fragColor.x += (0.1*p2.y + 0.1*p2.x + 0.05*time);
    
    // map to rgp space
    fragColor = HsvToRgb(fragColor);
}