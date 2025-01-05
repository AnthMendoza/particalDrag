#ifndef  PARTICLES_H
#define  PARTICLES_H

#include <array>
class particles
{
public:
    float positionX, positionY, positionZ;   
    float velocityX, velocityY, velocityZ; 
    float mass;

    particles(float positionX, float positionY, float positionZ, float velocityX, float velocityY, float velocityZ, float mass)
        : positionX(positionX), positionY(positionY), positionZ(positionZ), velocityX(velocityX), velocityY(velocityY), velocityZ(velocityZ), mass(mass) {}
    
};

void initParticles();

__global__ void updateState(particles *particle , size_t size , float timeStep);


__global__ void forceApplied(float forceX , float forceY , float forceZ , particles &particle , float &timeStep);

void initParticles();

void toCuda(particles *particle ,size_t size , float *timeStep);



void iterator(int stepCountLimit);

#endif
