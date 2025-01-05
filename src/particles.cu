#include "../include/particles.h"
#include "../include/constants.h"
#include <cuda_runtime.h>
#include <stdlib.h>
#include <iostream>

__global__ void updateState(particles *particle , int particleCount , float timeStep){


    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if(index< particleCount){
        particle[index].positionX += particle[index].velocityX * timeStep;
        particle[index].positionY += particle[index].velocityY * timeStep;
        particle[index].positionZ += particle[index].velocityZ * timeStep;
    }

}


__global__ void forceApplied(float forceX , float forceY , float forceZ , particles &particle , float &timeStep){
    particle.velocityX += (forceX / particle.mass) * timeStep;
    particle.velocityY += (forceY / particle.mass) * timeStep;
    particle.velocityZ += (forceZ / particle.mass) * timeStep;

}





void toCuda(particles *particle ,size_t size , float *timeStep , int *particleCount){
    particles *particlesCuda;
    float *timeStepCuda;

    cudaMalloc(&particlesCuda , size);

    cudaMemcpy(particlesCuda , particle , size ,cudaMemcpyHostToDevice);

    cudaMalloc(&timeStepCuda , sizeof(float));
    
    cudaMemcpy(timeStepCuda , timeStep, sizeof(float),cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (constants::particleCount + threadsPerBlock - 2) / threadsPerBlock;
    updateState<<<blocksPerGrid, threadsPerBlock>>>(particlesCuda , *particleCount  ,*timeStepCuda);
    cudaDeviceSynchronize();
    cudaMemcpy(particle,particlesCuda,size, cudaMemcpyDeviceToHost);

    for(int i = 0 ; i < size ; i++){

        std::cout<< particle[i].positionX << " , " << particle[i].positionY << " , " << particle[i].positionZ ;

    }
}



void iterator(int stepCountLimit){

    for(int i = 0 ; i < stepCountLimit ; i++){



    }

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
    toCuda(particleData , size , &constants::timeStep , &constants::particleCount);
}




