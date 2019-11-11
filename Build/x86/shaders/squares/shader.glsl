#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

// created by dariusz kosz (dars26)

float size = 24.0;
float edgeSize = 4.0;

float noisef(vec2 p) {
    return fract(dot(sin(p.x * 123.12)*142.,cos(p.y *34.95)*165.47));
}

void main()
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float ratio = iResolution.x / iResolution.y;
	
    float dx = 1./size;
    float dy = dx*ratio*0.9;
    
    vec2 coord = vec2(dx*floor(uv.x/dx), dy*floor(uv.y/dy)) + dx/2.0;
    vec4 noise = vec4(noisef(coord));
    
    vec2 m = vec2(iMouse.x, iMouse.y);
    float dist = 1.-distance(m/iResolution.xy, coord)*3.5;
    dist = step(0.6, dist);

    vec4 c_in = vec4(noise.x, noise.y, coord.x, 0.);

	float grad_off = 0.001 * edgeSize + 0.001*dist*10.;
    float freq = size * 2. * noise.y;
    float freq_offset = (3.+36.*dist)*iTime * noise.x;
	float amp = 0.006;
	vec4 borderCol = vec4(0.0);
	float gradient = 0.1;
	vec4 col = c_in+vec4(0.4)*dist;
    vec4 ssm = vec4(1., 1., 1., 1.) * 0.95; // square size 

    float sin_v = sin(freq_offset + uv.x*freq)*amp;
    float verical = sin_v + coord.y;
    
    float bottom = verical + dy*0.6 * ssm.x;
    gradient = smoothstep(bottom - grad_off, bottom, uv.y);
	col = mix(col, borderCol , gradient);		

    float top = verical - dy*0.25 * ssm.y;
    gradient = smoothstep(top + grad_off, top, uv.y);
	col = mix(col, borderCol , gradient);
	
    float sin_h = sin(freq_offset +uv.y*freq)*amp;
    float horizontal = sin_h + coord.x;
    
    float left = horizontal - dx * 0.45 * ssm.z;
    gradient = smoothstep(left + grad_off, left, uv.x);
    col = mix(col, borderCol , gradient);
	
	float right = horizontal + dx * 0.45 * ssm.a;
    gradient = smoothstep(right - grad_off, right, uv.x);
    col = mix(col, borderCol , gradient);
	
    
    //////////////////////////////////////////////
    // second layer

    vec4 noise2 = vec4(noisef(coord / 100.0 + iTime*0.009));
	c_in = vec4(coord.y, coord.x, noise.z, 0.); 
    
	borderCol = col;
    
    vec4 c_add = c_in * sin(noise2.x);
	col = mix(c_add+vec4(0.4)*dist, col, 0.62);
	
    ssm = vec4(1., 1., 1., 1.) * 0.79; // square size

    verical = -sin_v + coord.y;
    bottom = verical + dy*0.6 * ssm.x;
    gradient = smoothstep(bottom - grad_off, bottom, uv.y);
	col = mix(col, borderCol , gradient);		

    top = verical - dy*0.25 * ssm.y;
    gradient = smoothstep(top + grad_off, top, uv.y);
	col = mix(col, borderCol , gradient);
	
    horizontal = -sin_h + coord.x;
    left = horizontal - dx * 0.45 * ssm.z;
    gradient = smoothstep(left + grad_off, left, uv.x);
    col = mix(col, borderCol , gradient);
	
	right = horizontal + dx * 0.45 * ssm.a;
    gradient = smoothstep(right - grad_off, right, uv.x);
    col = mix(col, borderCol , gradient);
    
    fragColor = col;
}