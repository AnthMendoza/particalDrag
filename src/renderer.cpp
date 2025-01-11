#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <cuda_runtime.h>
#include <cuda_gl_interop.h>
#include <stdio.h>

// CUDA kernel to modify vertices
__global__ void updateVertices(float4* positions, float time) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    positions[idx].x = positions[idx].x * sinf(time);
    positions[idx].y = positions[idx].y * cosf(time);
}

// Vertex shader
const char* vertexShaderSource = R"(
    #version 330 core
    layout (location = 0) in vec4 position;
    void main() {
        gl_Position = position;
    }
)";

// Fragment shader
const char* fragmentShaderSource = R"(
    #version 330 core
    out vec4 FragColor;
    void main() {
        FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    }
)";

int main() {
    // Initialize GLFW and OpenGL
    if (!glfwInit()) {
        return -1;
    }

    GLFWwindow* window = glfwCreateWindow(800, 600, "CUDA-OpenGL Interop", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    if (glewInit() != GLEW_OK) {
        return -1;
    }

    // Create and compile shaders
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);

    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);

    GLuint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    // Create triangle vertices
    float vertices[] = {
        -0.5f, -0.5f, 0.0f, 1.0f,
         0.5f, -0.5f, 0.0f, 1.0f,
         0.0f,  0.5f, 0.0f, 1.0f
    };

    // Create OpenGL buffer
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);

    // Register buffer with CUDA
    cudaGraphicsResource* cuda_vbo_resource;
    cudaGraphicsGLRegisterBuffer(&cuda_vbo_resource, VBO, cudaGraphicsMapFlagsWriteDiscard);

    // Set up vertex attributes
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(float), 0);
    glEnableVertexAttribArray(0);

    float time = 0.0f;
    
    while (!glfwWindowShouldClose(window)) {
        // Map OpenGL buffer for writing from CUDA
        float4* dPtr;
        size_t size;
        cudaGraphicsMapResources(1, &cuda_vbo_resource);
        cudaGraphicsResourceGetMappedPointer((void**)&dPtr, &size, cuda_vbo_resource);

        // Launch CUDA kernel
        updateVertices<<<1, 3>>>(dPtr, time);
        cudaDeviceSynchronize();

        // Unmap buffer
        cudaGraphicsUnmapResources(1, &cuda_vbo_resource);

        // Render
        glClear(GL_COLOR_BUFFER_BIT);
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(window);
        glfwPollEvents();

        time += 0.01f;
    }

    // Cleanup
    cudaGraphicsUnregisterResource(cuda_vbo_resource);
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    glfwTerminate();
    return 0;
}