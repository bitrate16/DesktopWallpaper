```
Build/x86 - ready application
./ - source code
```

Can run any shader from [shadertoy.com](https://shadertoy.com)
------------------------------------


[Download release](https://github.com/bitrate16/DesktopWallpaper/releases)
--------------------------------------------------------------------------


_Following code should be inserted into shader beginning_
```
#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;

vec2 fragCoord = gl_FragCoord.xy;
out vec4 fragColor;
```

_Shader entry point_
```
void mainImage(out vec4 fragColor, in vec2 fragCoord)
```
_Should be replaced with_
```
void main()
```

_Running examples_
------------------
To start an example from __shaders__ folder - simply copy __fragment_shader.glsl__ to program root directory and do __Reload shader__