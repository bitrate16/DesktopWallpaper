#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;

// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// by Tomasz Dobrowolski' 2018

// Random Delaunay triangulation on regular grid.

// +LMB to see distance to Voronoi edges

// This is a response to Shane, who wrote:
// "I'm writing a wish list, an out-of-the-box way to cheaply produce
//  a geometric Delaunay triangulation of random 2D points"
// in https://www.shadertoy.com/view/Xsyczh

// I wouldn't describe my method "out of the box", as it is more or
// less straigh-forward implementation for heavily restricted
// point set on a regular grid.
// Nevertheless, enjoy!

// Also check out PolyCube's edition with panning/zooming:
// http://polycu.be/edit/?h=M963jR

#define FLIP_ANIMATION 1

// Hash variation by Shane,
// from https://www.shadertoy.com/view/4dSfzD
vec2 hashPt(vec2 p, float timeOffset) {
   float n = sin(dot(p, vec2(41, 289)));
   // Animated.
   p = fract(vec2(262144, 32768)*n);
   return sin( p*6.2831853 + timeOffset )*.5 + .5;
}

// We generate point in the cell center
// restricted in movement to box half the cell width/height,
// so Delaunay triangles behaves regularly.
vec2 cellPt(vec2 p) {
    return p + .5 + (hashPt(p, iTime) - .5)*.5;
}

// Fast distance to edge-Voronoi.
// Since seed positions are heavily restricted,
// 3x3 check is enough to search for a closest point
// as well as search for a pair of neighbours.
vec2 edgeVoronoi(vec2 p) {
   vec2 h, pH = floor(p);

   vec2 mh = cellPt(pH) - p;
   float md = 8.0;
   for (int j=-1; j<=1; ++j )
   for (int i=-1; i<=1; ++i ) {
      h = cellPt(pH + vec2(i,j)) - p;
      float d = dot(h, h);
      if (d < md) {
         md = d;
         mh = h;
      }
   }

   const float eps = .0001;
   float ed = 8.0;

   for (int j=-1; j<=1; ++j )
   for (int i=-1; i<=1; ++i ) {
      h = cellPt(pH + vec2(i,j)) - p;
      if (dot(h-mh, h-mh) > eps)
         ed = min( ed, dot( 0.5*(h+mh), normalize(h-mh) ) );
   }
   return vec2(sqrt(md),ed);
}

// Signed distance to a line crossing (p0, p1) segment.
float distLine( vec2 p0, vec2 p1 ) {
   vec2 e0 = p1 - p0;
   return dot( p0, normalize(vec2(e0.y,-e0.x)) );
}

// Use "parabolic lifting" method to calculate if two triangles are about to flip.
// This is actually more reliable than circumscribed circle method.
// The technique is based on duality between Delaunay Triangulation
// and Convex Hull, where DT is just a boundary of convex hull
// of projected seeds onto paraboloid.
// We project (h1 h2 h3) triangle onto paraboloid
// and return the distance of the origin
// to a plane crossing projected triangle.
float flipDistance(vec2 h1, vec2 h2, vec2 h3)
{
   // Projects triangle on paraboloid.
   vec3 g1 = vec3(h1, dot(h1,h1));
   vec3 g2 = vec3(h2, dot(h2,h2));
   vec3 g3 = vec3(h3, dot(h3,h3));
   // Return signed distance of (g1, g2, g3) plane to the origin.
   #if FLIP_ANIMATION
     return dot(g1, normalize(cross(g3-g1, g2-g1)));
   #else
     // If we don't do animation, we are only interested in a sign,
     // so normalization is unnecessary.
   	 return dot(g1, cross(g3-g1, g2-g1));
   #endif
}

// Find distance to closest Delaunay edge in (h0, h1, h2, h3) quad.
float delaunayQuad(vec2 h0, vec2 h1, vec2 h2, vec2 h3) {
   // Get distance to quad (note: in general it can be concave, but we don't care).
   float md = min(
      min(distLine(h0, h1), distLine(h1, h2)),
      min(distLine(h2, h3), distLine(h3, h0)));
   if (md < 0.0)
      return 8.0; // outside of the quad

   // Calculate flip distance relative to h2, but any other point would do.
   float dc = flipDistance(h0 - h2, h1 - h2, h3 - h2);

   #if FLIP_ANIMATION
     float f = clamp(dc*6. + .5, 0., 1.);
   #else
     float f = float(dc > 0.0);
   #endif
   // Flipping rotates diagonal from (h0 h2) to (h3 h1).
   // Calculate distance to diagonal (positive from both sides).
   return min(md, abs(distLine(mix(h0, h3, f), mix(h2, h1, f))));
}

// Final function visits 4 quads around the center cell.
float delaunayTriangulation(vec2 p) {
   vec2 pH = floor(p);

   vec2 o = cellPt(pH) - p;
   // Go clock-wise around center cell.
   vec2 h0 = cellPt(pH + vec2(-1, 0)) - p;
   vec2 h1 = cellPt(pH + vec2(-1,-1)) - p;
   vec2 h2 = cellPt(pH + vec2( 0,-1)) - p;
   vec2 h3 = cellPt(pH + vec2( 1,-1)) - p;
   vec2 h4 = cellPt(pH + vec2( 1, 0)) - p;
   vec2 h5 = cellPt(pH + vec2( 1, 1)) - p;
   vec2 h6 = cellPt(pH + vec2( 0, 1)) - p;
   vec2 h7 = cellPt(pH + vec2(-1, 1)) - p;

   float md =   delaunayQuad(h0,h1,h2,o);
   md = min(md, delaunayQuad(o,h2,h3,h4));
   md = min(md, delaunayQuad(h6,o,h4,h5));
   md = min(md, delaunayQuad(h7,h0,o,h6));
   return md;
}

// Do shading with pseudo-linear color space and fake anti-aliasing.
vec3 lin(vec3 col) { return col*col; }
vec3 gamma(vec3 col) { return sqrt(max(vec3(0),col-.03)); }
vec3 shade(float tri, float dist, vec2 ev, float ss) {
   ss *= .6;
   return
    mix(
     mix(
      mix(
       mix(
        mix(
         lin(vec3(.7,.5,1.))*(dist*2.2 + .1),
         lin(vec3(.7,.6,1.)),
         smoothstep(.03+ss,.03-ss,ev.y)*.3
        ),
        vec3(0), // edge shadow
        smoothstep(.05,.01+ss,tri)*.3
       ),
       lin(vec3(1.,.7,.3)),
       max(
        smoothstep(ss*2.,0.,abs(fract(dist*8.+.5)-.5)/8.)*.7*step(1./16.,dist),
        smoothstep(.01+ss,.01-ss,tri))
      ),
      vec3(0), // seed point shadow
      smoothstep(.08,min(.075,.05+ss),ev.x)*.7
     ),
     lin(vec3(1,.8,.5)),
     smoothstep(.05+ss,.05-ss,ev.x)
    );
}

void main()
{
    float ss = .01;
    vec2 p = (fragCoord.xy - iResolution.xy*.5)*ss;
    vec2 ev = edgeVoronoi(p);
    float tri = delaunayTriangulation(p);
    float dist = (iMouse.z > 0.) ? ev.y : tri;
    vec3 col = shade(tri, dist, ev, ss);
    fragColor = vec4(gamma(col), 1);
}
