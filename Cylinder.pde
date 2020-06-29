final float cylinderBaseSize =30;
final float cylinderHeight = 50;
final int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape closed = new PShape();

void buildCylinder() 
{
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  
  //get the x and y position on a circle for all the sides
  for(int i = 0; i < x.length; i++) 
  {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
    
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);

  //draw the border of the cylinder
  for(int i = 0; i < x.length; i++) 
  {
    openCylinder.vertex(x[i],0 ,y[i]);
    openCylinder.vertex(x[i], cylinderHeight ,y[i]);
  }

  openCylinder.endShape();
  
  //draw the top and bottom of the cylinder
  closed = createShape();
  closed.beginShape(TRIANGLES);
  
  for (int i = 0; i < x.length-1 ; ++i) 
  {
    closed.vertex(x[i],0, y[i]);
    closed.vertex(x[i+1],0 , y[i+1]);
    closed.vertex(0, 0, 0);

    closed.vertex(x[i],cylinderHeight , y[i]);
    closed.vertex(x[i+1],cylinderHeight , y[i+1]);
    closed.vertex(0, cylinderHeight, 0);
  }

  closed.endShape();
}


void drawCylinder() 
{
  for (PVector vect : cylinder) 
  {
    pushMatrix();
 
    translate(-vect.x, -cylinderHeight, vect.y);
    openCylinder.setFill(color(0, 139, 0));
    openCylinder.setStroke(color(202, 255, 112));
    shape(openCylinder);
    
    closed.setFill(color(0, 139, 0));
    closed.setStroke(color(202, 255, 112));
    shape(closed);

    popMatrix();
  }
}
