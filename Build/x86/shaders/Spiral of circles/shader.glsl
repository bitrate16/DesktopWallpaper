#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

#define A_CH   0.25
#define B_CH   0.75
#define R_SC   4.0
#define PERIOD 2.0
#define PI     3.14159265358979323846
#define THICK  0.5
#define SPEED  16.0
#define RADMUL 24.8

// Source: https://www.shadertoy.com/view/Md2yWR

const float MATH_PI	= float( 3.14159265359 );

void Rotate( inout vec2 p, float a ) 
{
	p = cos( a ) * p + sin( a ) * vec2( p.y, -p.x );
}

float saturate( float x )
{
	return clamp( x, 0.0, 1.0 );
}

void main()
{    
    vec2 p = ( 2.0 * fragCoord - iResolution.xy ) / iResolution.x * 1000.0;
    
    float sdf = 1e6;
    float dirX = 0.0;
    for ( float iCircle = 1.0; iCircle < 16.0 * 4.0 - 1.0; ++iCircle )
    {
        float circleN = iCircle / ( 16.0 * 4.0 - 1.0 );
        float t = fract( circleN + iTime * 0.2 );
        
        float offset = -180.0 - 330.0 * t;
        float angle  = fract( iCircle / 16.0 + iTime * 0.01 + circleN / 8.0 );
        float radius = mix( 50.0, 0.0, 1.0 - saturate( 1.2 * ( 1.0 - abs( 2.0 * t - 1.0 ) ) ) );
        
        vec2 p2 = p;
        Rotate( p2, -angle * 2.0 * MATH_PI );
        p2 += vec2( -offset, 0.0 );
        
        float dist = length( p2 ) - radius;
        if ( dist < sdf )
        {
            dirX = p2.x / radius;
            sdf	 = dist;
        }
    }
    
    vec3 colorA = vec3( 24, 30, 28 );
    vec3 colorB = vec3( 249, 249, 249 );
    
    vec3 abberr = colorB;
	abberr = mix( abberr, vec3( 205, 80, 28 ), saturate( dirX ) );
    abberr = mix( abberr, vec3( 38, 119, 208 ), saturate( -dirX ) );
    
    colorB = mix( colorB, abberr, smoothstep( 0.0, 1.0, ( sdf + 5.0 ) * 0.1 ) );
    
    vec3 color = mix( colorA, colorB, vec3( 1.0 - smoothstep( 0.0, 1.0, sdf * 0.3 ) ) );
	fragColor = vec4( color / 255.0, 1.0 );
}