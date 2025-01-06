#include <iostream>
#include "../include/particles.h"
#include "../include/constants.h"
#include <chrono>



int main(){
	auto start = std::chrono::high_resolution_clock::now();
	initParticles();

	auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> duration = end - start;
        std::cout << "Runtime: " << duration.count() << " seconds" << "\n";
	
}
