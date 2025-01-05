#include "../include/particles.h"
#include "../include/constants.h"
#include <cuda_runtime.h>
#include <stdlib.h>
#include <iostream>

__global__ void updateState(particles *particle , size_t size){


    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if(index<size){
        particle[index].positionX +- particle[index].velocityX * constants::timeStep;
        particle[index].positionY +- particle[index].velocityY * constants::timeStep;
        particle[index].positionZ +- particle[index].velocityZ * constants::timeStep;
    }

}


__global__ void forceApplied(float forceX , float forceY , float forceZ , particles &particle){
    particle.velocityX += (forceX / particle.mass) * constants::timeStep;
    particle.velocityY += (forceY / particle.mass) * constants::timeStep;
    particle.velocityZ += (forceZ / particle.mass) * constants::timeStep;

}


void initParticles(){

    size_t size = constants::particleCount * sizeof(particles);

    particles *particleData = (particles*)malloc(size);

    for(int i = 0 ; i < constants::particleCount ; i++ ){

        particleData[i].positionX = constants::gridSizeX * i / constants::particleCount;
        particleData[i].positionY = constants::gridSizeY * i / constants::particleCount;
        particleData[i].positionZ = constants::gridSizeZ * i / constants::particleCount;

        particleData[i].velocityX = 0;
        particleData[i].velocityY = 0;
        particleData[i].velocityZ = 0;
        
        particleData[i].mass = constants::mass; 

    }
    toCuda(particleData , size);
}


void toCuda(particles *particle ,size_t size){
    particles *particlesCuda;
    cudaMalloc(&particlesCuda , size);

    cudaMemcpy(particlesCuda , particle , size ,cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (size + threadsPerBlock - 1) / threadsPerBlock;

    updateState<<<blocksPerGrid, threadsPerBlock>>>(particlesCuda , size);


    int threadsPerBlock = 256;
    int blocksPerGrid = (constants::particleCount + threadsPerBlock - 1) / threadsPerBlock;
    updateState<<<blocksPerGrid, threadsPerBlock>>>(particlesCuda , size);

    cudaMemcpy(particle,particlesCuda,size, cudaMemcpyDeviceToHost);

    for(int i = 0 ; i < size ; i++){

        std::cout<< particle[i].positionX << " , " << particle[i].positionY << " , " << particle[i].positionZ ;

    }
}



void iterator(int stepCountLimit){

    for(int i = 0 ; i < stepCountLimit ; i++){



    }

}





