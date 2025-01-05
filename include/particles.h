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

#endif
