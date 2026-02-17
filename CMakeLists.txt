cmake_minimum_required(VERSION 3.14)
project(tpms_render CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_PREFIX_PATH "C:/glfw")
list(APPEND CMAKE_PREFIX_PATH "C:/glew-2.3.1/")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(test main.cpp)

find_package(glfw3 3.3 REQUIRED)
find_package(GLEW REQUIRED)
find_package(glm REQUIRED)
find_package(OpenGL REQUIRED)

# glfw
target_link_libraries(test PRIVATE glfw)

# glew
target_link_libraries(test PRIVATE GLEW)

# opengl
target_link_libraries(test PRIVATE OpenGL::GL)

# extras
target_include_directories(test PRIVATE "~/ornl/glextras")

#copy all glsl files to build folder
file(GLOB_RECURSE GLSL_FILES "*.glsl")

foreach(glsl_file ${GLSL_FILES})
    configure_file(${glsl_file} . COPYONLY)
endforeach(glsl_file)

# Windows system libs commonly needed
if (WIN32)
  target_link_libraries(test PRIVATE opengl32 user32 gdi32 shell32)
endif()
