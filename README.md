# tpms_cubespin

This is a small demo project that performs ray-tracing on an analytically defined TPMS level surface. It renders the surface within a cube bounding mesh. It uses a fixed light source relative to the model. Rendering is done in a GLSL fragment shader. This shader casts a ray from the camera and moves along fixed intervals within the cube until it finds a zero crossing, at which point it iteratively bisects the line segment under examination 64 times and returns the result.

The root-finding algorithm is likely quite suboptimal, but it is good enough for a fairly rough render. The shader also finds the normal of the surface at the root and uses that for lighting.

Currently it supports the following gyroids. To switch between gyroids, define a preprocessor constant with the corresponding name:

- GYROID
- DIAMOND
- SCHWARZ_P
- SPLIT_P

## Build

Tested on Linux with CMake and with relevant libraries installed. Dependencies include:

- OpenGL
- GLM
- GLFW
- GLEW

There may be other dependencies (I've only tried to deploy it on my own machines).

## Running

In the build folder, the executable is ./test. It takes an optional argument, a float "frequency," which will determine the frequency of the function.
