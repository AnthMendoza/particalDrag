#include <iostream>
#include <cuda_runtime.h>
#include <GL/gl.h>
#include "../include/particles.h"
#include "../include/constants.h"
#include "../include/renderer.h"
#include <chrono>
#include <iostream>



int main(){
	auto start = std::chrono::high_resolution_clock::now();

    //GLuint vbo;
    //cudaGraphicsResource *cudaVboResource;

	//initParticleBuffer(cudaVboResource , vbo);

	initParticles();


	auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> duration = end - start;
        std::cout << "Runtime: " << duration.count() << " seconds" << "\n";
	
}
