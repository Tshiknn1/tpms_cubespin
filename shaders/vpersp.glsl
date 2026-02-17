#version 330 core

layout(location = 0) in vec3 aPos;
// there was once something here...
layout(location = 2) in vec2 aTexCoord;

out vec4 fragPosView;
out vec3 rayDirection;

uniform mat4 trans;
uniform mat4 projection;
uniform mat4 transInv;

void main() {
    gl_Position = projection * trans * vec4(aPos, 1.0);
    fragPosView = trans * vec4(aPos, 1.0);
    rayDirection = normalize(fragPosView.xyz);
}
