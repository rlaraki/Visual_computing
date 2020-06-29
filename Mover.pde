class Mover 
{
  
PImage img;
PShape globe;

PVector location;
PVector velocity;
PVector gravityForce = new PVector(0, 0, 0);
final float gravityConstant = 1.4;
final float rayon = 30;
PVector friction = new PVector(0,0,0);

final float normalForce = 1;
final float mu = 0.3;
final float frictionMagnitude = normalForce * mu;

Mover() 
{
  location = new PVector(0, 0, 0);
  velocity = new PVector(0, 0, 0);
  img = loadImage("foin.jpg");
  globe = createShape(SPHERE, rayon);
  globe.setStroke(false);
  globe.setTexture(img);
}
  
void update() 
{
  friction = velocity.get();
  friction.mult(-1);
  friction.normalize();
  friction.mult(frictionMagnitude);
    
  gravityForce.x = sin(rotZ) * gravityConstant;
  gravityForce.z = -sin(rotX) * gravityConstant;

  velocity.add(gravityForce).add(friction);
  location.add(velocity);
  

}

void display() 
{
  noStroke();
  lights();

  translate(location.x, location.y, location.z);
 // fill(255, 255, 255);
 // sphere(rayon);

  shape(globe);

}
  
void checkEdges() 
{
  if (location.x + rayon > longueur_box/2.0) 
  {
    velocity.x = - velocity.x;
    location.x = longueur_box/2.0 - rayon;
    totalScore -= velocity.mag();
    lastPoints = -velocity.mag();
    scoreEvolved = true;
  }
  else if (location.x - rayon < -longueur_box/2.0) 
  {
    velocity.x = - velocity.x;
    location.x = -longueur_box/2.0 + rayon;
    totalScore -= velocity.mag();
    lastPoints = -velocity.mag();
    scoreEvolved = true;
  }
  if (location.z + rayon > largeur_box/2.0) 
  {
    velocity.z = - velocity.z;
    location.z = largeur_box/2.0 - rayon;
    totalScore -= velocity.mag();
    lastPoints = -velocity.mag();
    scoreEvolved = true;
  }
  else if (location.z - rayon < -largeur_box/2.0) 
  {
    velocity.z = - velocity.z;
    location.z = -largeur_box/2.0 + rayon;
    totalScore -= velocity.mag();
    lastPoints = -velocity.mag();
    scoreEvolved = true;
  }
}

void checkCylinderCollision() 
{
  for (PVector vector : cylinder) 
  {
    PVector vector3D = new PVector(-vector.x, 0, vector.y);
    
    if (PVector.dist(vector3D, location) <= rayon + cylinderBaseRadius) 
    {
      PVector n = PVector.sub(location, vector3D).normalize();
      float v1dotn = PVector.dot(velocity, n);
        
      velocity = PVector.sub(velocity, PVector.mult(n, 2 * v1dotn));
        
      PVector sphereBouncing = PVector.mult(n, cylinderBaseRadius + rayon);
      location.x = vector3D.x + sphereBouncing.x;
      location.z = vector3D.z + sphereBouncing.z;
      totalScore += velocity.mag();
      lastPoints = velocity.mag();
      scoreEvolved = true;
    }
    
  }
  
}
  
}
