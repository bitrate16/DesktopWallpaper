```
Build/x86 - ready application
./ - source code
```

Can run any shader from [shadertoy.com](https://shadertoy.com)
------------------------------------

_Code should be inserted into shader beginning_
```
#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;
```

_Entry point should be replaced_
```
void mainImage(out vec4 fragColor, in vec2 fragCoord)
```
_With_
```
void main()
```

_Running examples_
------------------
To start an example from __shaders__ folder - simply copy __fragment_shader.glsl__ to program root directory and do __reload shader__