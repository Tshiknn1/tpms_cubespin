#version 330 core

layout(location = 0) in vec3 aPos;
// layout(location = 1) in vec3 aColor;
layout(location = 2) in vec2 aTexCoord;

//out vec3 ourColor;
out vec4 fragPosView;
out vec3 rayDirection;

uniform mat4 trans;
uniform mat4 projection;
uniform mat4 transInv;

void main() {
    gl_Position = projection * trans * vec4(aPos, 1.0);
    //ourColor = aColor;
    fragPosView = trans * vec4(aPos, 1.0);
    rayDirection = normalize(fragPosView.xyz);
}
