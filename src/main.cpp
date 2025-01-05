#include <iostream>
#include "../include/particles.h"
#include "../include/constants.h"



int main(){
	particles *particle = initParticles();



	for(int i = 0; i < constants::particleCount ; i++){

		std::cout<< i << " , (" << particle[i].positionX << " , " <<  particle[i].positionY << " , " << particle[i].positionZ << " ) \n";
	}
	return 0;
}
