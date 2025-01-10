#include "../include/particles.h"
#include "../include/constants.h"
#include <cuda_runtime.h>
#include <stdlib.h>
#include <iostream>
#include <random>
#include <cmath>


__global__ void updateState(particles *particle , int particleCount,  float timeStep){

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if(index< particleCount){
        particle[index].positionX = particle[index].velocityX * timeStep;
        particle[index].positionY = particle[index].velocityY * timeStep;
        particle[index].positionZ = particle[index].velocityZ * timeStep;
        
    }


}


__global__ void iterator(particles *particlesCuda , size_t size , int particleCount){
    cudaEvent_t start, stop;
    float milliseconds = 0;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    

    int threadsPerBlock = 256;
    int blocksPerGrid = (particleCount + threadsPerBlock - 1) / threadsPerBlock;

    while(true){
        cudaEventRecord(start);
    
        updateState<<<blocksPerGrid, threadsPerBlock>>>(particlesCuda , particleCount , milliseconds);

        cudaDeviceSynchronize();

        cudaEventRecord(stop);

        cudaEventSynchronize(stop);

        cudaEventElapsedTime(&milliseconds, start, stop);

    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
}


__global__ void forceApplied(float forceX , float forceY , float forceZ , particles *particle , int index , float timeStep){
    particle[index].velocityX += (forceX / particle[index].mass) * timeStep;
    particle[index].velocityY += (forceY / particle[index].mass) * timeStep;
    particle[index].velocityZ += (forceZ / particle[index].mass) * timeStep;

}



__global__ void containerBounds(particles &particle , float containerX , float containerY , float containerZ){

    if(particle.positionX > containerX ){
        particle.velocityX = -particle.velocityX;
        particle.positionX = containerX;
    }
    if(particle.positionX < 0 ){
        particle.velocityX = -particle.velocityX;
        particle.positionX = 0;
    }

    if(particle.positionY > containerY ){
        particle.velocityY = -particle.velocityY;
        particle.positionY = containerY;
    }
    if(particle.positionY < 0 ){
        particle.velocityY = -particle.velocityY;
        particle.positionY = 0;
    }

    if(particle.positionZ > containerZ ){
        particle.velocityZ = -particle.velocityZ;
        particle.positionZ = containerZ;
    }
    if(particle.positionZ < 0 ){
        particle.velocityZ = -particle.velocityZ;
        particle.positionZ = 0;
    }

}



__global__ void kernelFunction(particles &mainParticle , particles &interactionParticle , float radius , float smoothingLength , float *kernelValue){
    float distanceFactor = radius/smoothingLength;


    if( distanceFactor <= 1){ 
        *kernelValue = (1 /(3.1415926f * smoothingLength * smoothingLength * smoothingLength))*(1 - 3/2 * powf((distanceFactor),2) + 3/4 * powf((distanceFactor),3));
    }

    if(distanceFactor <= 2){
        
    *kernelValue = (1 /(3.1415926 * smoothingLength * smoothingLength * smoothingLength))*(1/4) * powf((2-(distanceFactor)),3);
    } 
    if(distanceFactor > 2){
        *kernelValue = 0.0f;
    }

}



void printParticles(particles *particle){
    for( int i = 0; i < constants::particleCount ; i++){
        std::cout<< i << " : ( " << particle[i].positionX << " , " << particle[i].positionY << " , " << particle[i].positionZ << " ) \n";
    }
}


void partition(){
    
}



void toCuda(particles *particle ,size_t size , int particleCount){
    particles *particlesCuda;

    cudaError_t err = cudaMalloc(&particlesCuda , size);

    if(err != cudaSuccess){
        std::cerr << "Failed to allocate device memory (particlesCuda): " << cudaGetErrorString(err) << std::endl;
        return;
    }

    cudaMemcpy(particlesCuda , particle , size ,cudaMemcpyHostToDevice);

    iterator(particlesCuda , size , constants::particleCount);


    err = cudaGetLastError();
    if (err != cudaSuccess) {
        std::cerr << "Kernel launch failed: " << cudaGetErrorString(err) << std::endl;
        cudaFree(particlesCuda);
        return;
    }


    cudaDeviceSynchronize();
    cudaMemcpy(particle,particlesCuda,size, cudaMemcpyDeviceToHost);

    cudaFree(particlesCuda);
}



float getRandomFloat(float min, float max) {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(min, max);
    return dis(gen);
}



void initParticles(){

    size_t size = constants::particleCount * sizeof(particles);

    particles *particleData = (particles*)malloc(size);

    for(int i = 0 ; i < constants::particleCount ; i++ ){

        particleData[i].positionX = getRandomFloat(0.0f , constants::gridSizeX);
        particleData[i].positionY = getRandomFloat(0.0f , constants::gridSizeY);
        particleData[i].positionZ = getRandomFloat(0.0f , constants::gridSizeZ);

        particleData[i].velocityX = .5;
        particleData[i].velocityY = 0;
        particleData[i].velocityZ = 0;
        
        particleData[i].mass = constants::mass; 

    }


    toCuda(particleData , size, constants::particleCount);

    free(particleData);

}




