#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <GL/glext.h>
#include <GL/freeglut.h>
#include <GL/gl.h>

#include <stdio.h>

#include <cmath>

#define STB_IMAGE_IMPLEMENTATION
#define STBI_FAILURE_USERMSG

#include "shader_helper.h"
#include "stb_image.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#define VERT_SHADER "vpersp.glsl"
#define FRAG_SHADER "frag.glsl"

// make a cube
//float vertices[] = {
//    -0.5f, -0.5f, -0.5f,
//    -0.5f, 0.5f, -0.5f,
//    -0.5f, -0.5f, 0.5f,
//    -0.5f, 0.5f, 0.5f,
//    0.5f, -0.5f, -0.5f,
//    0.5f, 0.5f, -0.5f,
//    0.5f, -0.5f, 0.5f,
//    0.5f, 0.5f, 0.5f
//};

//float vertices[] = {
//    0.5f, 0.5f, 0.0f,
//    0.5f, -0.5f, 0.0f,
//    -0.5f, -0.5f, 0.0f,
//    -0.5f, 0.5f, 0.0f
//};

//float vertices[] = {
//    1.0f, 1.0f, 0.0f,   1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
//    1.0f, -1.0f, 0.0f,  1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
//    -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f,
//    -1.0f, 1.0f, 0.0f,  0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
//};
unsigned int indices[] = {
    0, 1, 3,
    1, 2, 3
};

float vertices[] = {
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
     0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};


//float vertices[] = {
//    -0.5f, -0.5f, 0.0f, // left  
//     0.5f, -0.5f, 0.0f, // right 
//     0.0f,  0.5f, 0.0f  // top   
//};


void APIENTRY DebugCallback(GLenum source,
                            GLenum type,
                            GLuint id,
                            GLenum severity,
                            GLsizei length,
                            const GLchar* message,
                            const void* userParam)
{
    std::cerr << "GL DEBUG: " << message << std::endl;
}


int main(int argc, const char** argv) {
    float freqScale = 1.f;
    if (argc > 1) {
        freqScale = atof(argv[1]);
    }

    printf("hi\n");

    if (!glfwInit()) {
        return -1;
    }

    GLFWwindow* window = glfwCreateWindow(640, 480, "test window", NULL, NULL);
    glfwMakeContextCurrent(window);

    if (glewInit() != GLEW_OK) {
        return -1;
    }

    // enable debug output
    glEnable(GL_DEBUG_OUTPUT);
    glDebugMessageCallback(DebugCallback, nullptr);

    // load shaders
    unsigned int vertexShader, fragmentShader;
    vertexShader = load_shader(VERT_SHADER, GL_VERTEX_SHADER);
    fragmentShader = load_shader(FRAG_SHADER, GL_FRAGMENT_SHADER);

    // create program
    unsigned int shaderProgram;
    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    int success = 0;
    char infoLog[512];
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
    }

    glDisable(GL_DEBUG_OUTPUT);


    // use the program
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    // generate a vertex buffer
    unsigned int vbo, vao, ebo;
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &vbo);
//    glGenBuffers(1, &ebo);

    glBindVertexArray(vao);

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // enable vertex attributes
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*) 0);
    glEnableVertexAttribArray(0);
//    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*) (3 * sizeof(float)));
//    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*) (2 * sizeof(float)));
    glEnableVertexAttribArray(2);

    // enable color attributes

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindVertexArray(0);

    // generate texture containers
    unsigned int texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // load image
    int width, height, nrChannels;
    unsigned char* data = stbi_load("raphtalia-wallpaper.jpg", &width, &height, &nrChannels, 0);
    if (!data) {
        fprintf(stderr, "couldn't load image...");
        exit(-1);
    }

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);

    stbi_image_free(data);

    // create model matrix
    glm::mat4 model = glm::mat4(1.0f);
    model = glm::rotate(model, glm::radians(45.0f), glm::vec3(1.0f, 1.0f, 1.0f));

    // create view matrix
    glm::mat4 view = glm::mat4(1.0f);
    view = glm::translate(view, glm::vec3(0.0f, 0.0f, -3.0f));

    // create projection matrix
    glm::mat4 projection;
    projection = glm::perspective(glm::radians(45.0f), 800.0f / 600.0f, 0.5f, 100.0f);

    glm::mat4 transformation = view * model;
    glm::mat4 transInv = glm::inverse(transformation);

    glm::vec4 cameraPos = transInv * glm::vec4(0.f, 0.f, 0.f, 1.f);

    glm::vec4 lightPos = glm::vec4(0.f, -10.f, 5.f, 1.f);

    // setup rotation transform
    //trans = glm::rotate(trans, glm::radians(90.0f), glm::vec3(0.0, 0.0, 1.0));
    //trans = glm::scale(trans, glm::vec3(0.5, 0.5, 0.5));

    while (!glfwWindowShouldClose(window)) {
        //processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glEnable(GL_DEPTH_TEST);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        unsigned int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
        //unsigned int modelLoc = glGetUniformLocation(shaderProgram, "model");
        //unsigned int viewLoc = glGetUniformLocation(shaderProgram, "view");
        unsigned int projectionLoc = glGetUniformLocation(shaderProgram, "projection");
        unsigned int transLoc = glGetUniformLocation(shaderProgram, "trans");
        unsigned int transInvLoc = glGetUniformLocation(shaderProgram, "transInv");
        unsigned int cameraPosLoc = glGetUniformLocation(shaderProgram, "cameraPos");
        unsigned int lightPosLoc = glGetUniformLocation(shaderProgram, "lightPos");
        unsigned int freqLoc = glGetUniformLocation(shaderProgram, "freq");

        float timeValue = glfwGetTime();
        float greenValue = (sin(timeValue) / 2.0f) + 0.5;

        //trans = glm::translate(trans, glm::vec3(0.5f, -0.5f, 0.0f));
        //glm::mat4 trans = glm::mat4(1.0f);
        glm::mat4 newModel = glm::rotate(model, (float) glfwGetTime(), glm::vec3(0.0f, 1.0f, 0.0f));

        transformation = view * newModel;
        transInv = glm::inverse(transformation);

        glUseProgram(shaderProgram);
        glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.2f, 1.0f);
        //glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
        //glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
        //glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
        glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));
        glUniformMatrix4fv(transLoc, 1, GL_FALSE, glm::value_ptr(transformation));
        glUniformMatrix4fv(transInvLoc, 1, GL_FALSE, glm::value_ptr(transInv));
        glUniform4fv(cameraPosLoc, 1, glm::value_ptr(cameraPos));
        glUniform4fv(lightPosLoc, 1, glm::value_ptr(lightPos));
        glUniform1f(freqLoc, freqScale);

        glBindTexture(GL_TEXTURE_2D, texture);
        glBindVertexArray(vao);
//        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
//        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
//        glBindVertexArray(0);
        glDrawArrays(GL_TRIANGLES, 0, 36);

        glfwSwapBuffers(window);
    //while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
    }

    glfwTerminate();

    return 0;
}
