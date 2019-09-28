```
Build/x86 - ready application
./ - source code
```

Can run any shader from shaderty.com
------------------------------------

_Code should be inserted into shader beginning_
```
#version 330 core

uniform float iTime;
uniform vec3 iResolution;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;
```

```
void mainImage(out vec4 fragColor, in vec2 fragCoord)
```
_Should be replaced with_
```
void main()
```