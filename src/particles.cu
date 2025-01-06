#include "../include/particles.h"
#include "../include/constants.h"
#include <cuda_runtime.h>
#include <stdlib.h>
#include <iostream>

__global__ void updateState(particles *particle , int particleCount , float timeStep){


    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if(index< particleCount){
        particle[index].positionX = particle[index].positionX * timeStep;
        particle[index].positionY = particle[index].positionY * timeStep;
        particle[index].positionZ = particle[index].positionZ * timeStep;
    }

}


__global__ void forceApplied(float forceX , float forceY , float forceZ , particles &particle , float &timeStep){
    particle.velocityX += (forceX / particle.mass) * timeStep;
    particle.velocityY += (forceY / particle.mass) * timeStep;
    particle.velocityZ += (forceZ / particle.mass) * timeStep;

}





void toCuda(particles *particle ,size_t size , float timeStep , int particleCount){
    particles *particlesCuda;

    cudaError_t err = cudaMalloc(&particlesCuda , size);

    if(err != cudaSuccess){
        std::cerr << "Failed to allocate device memory (particlesCuda): " << cudaGetErrorString(err) << std::endl;
        return;
    }

    cudaMemcpy(particlesCuda , particle , size ,cudaMemcpyHostToDevice);

    std::cout<< timeStep <<" , "<< particleCount << " , "<< size;

    int threadsPerBlock = 256;
    int blocksPerGrid = (constants::particleCount + threadsPerBlock - 1) / threadsPerBlock;
    
    updateState<<<blocksPerGrid, threadsPerBlock>>>(particlesCuda , particleCount  ,timeStep);


    err = cudaGetLastError();
    if (err != cudaSuccess) {
        std::cerr << "Kernel launch failed: " << cudaGetErrorString(err) << std::endl;
        cudaFree(particlesCuda);
        return;
    }


    cudaDeviceSynchronize();
    cudaMemcpy(particle,particlesCuda,size, cudaMemcpyDeviceToHost);

    //for(int i = 0 ; i < constants::particleCount ; i++){

      //  std::cout<< "( "<< particle[i].positionX << " , " << particle[i].positionY << " , " << particle[i].positionZ << " )";

    //}

    cudaFree(particlesCuda);
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


    toCuda(particleData , size , constants::timeStep , constants::particleCount);

    free(particleData);

}




