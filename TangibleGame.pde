import processing.video.*;

PGraphics background;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;
Mover mover;
final int longueur_box = 500;
final int largeur_box= 500;
final int hauteur_box= 15;
ArrayList<PVector> cylinder;
final int cylinderBaseRadius = 30;
          
final float default_d = .03;
float d = default_d;
final float dd = .005;
         
final float default_angle = 0;
float rotX = default_angle;
float rotZ = default_angle;
final float max_angle = PI / 3.0;
           
boolean shift_on = false;

int totalScore = 0;
float lastPoints = 0;
ArrayList<Integer> scores;
boolean scoreEvolved = false;

HScrollbar hScrollBar;

PImage img;
ImageProcessing imgproc;
Movie cam;

void settings() 
{
 size(1000, 900, P3D);
}
          
void setup() 
{
  cam = new Movie(this, "testvideo.avi"); //Put the video in the same directory
  cam.loop();

  if (cam.available() == true) 
  {
      cam.read();
  }
  img = cam.get();  
  
  imgproc = new ImageProcessing();
  String[] args = { "Image Processing Window" };
  PApplet.runSketch(args, imgproc);
  
  mover = new Mover();
  cylinder = new ArrayList<PVector>();
  buildCylinder();
  background = createGraphics(1000, 200, P2D);
  topView = createGraphics(150, 150, P2D);
  scoreBoard = createGraphics(180, 180, P2D);
  barChart = createGraphics(600, 160, P2D);
  scores = new ArrayList<Integer>();
  hScrollBar = new HScrollbar(370,  2.365*height/3 + barChart.height, barChart.width/2, 30);
}
           
           
void draw () 
{
    
  if(!shift_on)
  {
      
    if (cam.available() == true) 
    {
      cam.read();
    }
    img = cam.get();  
    
    PVector rotation = imgproc.rotation;
    
    rotX = rotation.z;
    rotZ = rotation.y;
    
    background(255);
    drawBackground();
    image(background, 0, 2.35*height/3);
    drawTopView();
    image(topView, 0, 2.425*height/3);
    drawScoreBoard();
    image(scoreBoard, 170, 2.365*height/3);
    drawBarChart();
    image(barChart, 370, 2.365*height/3);
   
    hScrollBar.update();
    hScrollBar.display();
    
    pushMatrix(); // drawing the box
           
    translate(width/2.0, height/2.0, 0);
    rotateX(rotX);
    rotateZ(rotZ);
    stroke(50);
    fill(223, 175, 44);
    box(longueur_box, hauteur_box, largeur_box);
            
    popMatrix();
            
    pushMatrix(); //drawing the cylinder(s)
           
    translate(width/2.0, height/2.0, 0);
    rotateX(rotX);
    rotateZ(rotZ);
    stroke(50);
    drawCylinder();
    popMatrix();
        
    pushMatrix(); // drawing the mover
 
    translate(width/2.0, height/2.0, 0);
    rotateX(rotX);
    rotateZ(rotZ);
    translate(0, -hauteur_box / 2.0 - mover.rayon, 0);
    mover.checkEdges();
    mover.checkCylinderCollision();
    mover.update();
    mover.display();
 
    popMatrix();
    
  } 
    
    else // when SHIFT is pressed
    {
                
      background(255);
      drawBackground();
      image(background, 0, 2.35*height/3);  
      drawTopView();
      image(topView, 0, 2.425*height/3);
      drawScoreBoard();
      image(scoreBoard, 170, 2.365*height/3);
    
      pushMatrix(); //drawing the box
           
      translate(width/2 - largeur_box/2.0, height/2.0 - longueur_box/2.0, 0);
      fill(223, 175, 44);
      rect(0,0,longueur_box, largeur_box);
            
      popMatrix();
            
      pushMatrix(); //drawing the mover
 
      translate(width/2.0, height/2.0, 0);
      rotateX(-PI/2);
      mover.checkEdges();
      mover.checkCylinderCollision();
      mover.display();
 
      popMatrix();
            
      pushMatrix(); //draxing the cylinder(s)
        
      translate(width/2.0, height/2.0, 0);
      rotateX(-PI/2);
      drawCylinder();
           
      popMatrix();
  
   }
         
}
  
void drawBackground()  
{
  background.beginDraw();
  background.background(250, 240, 197);
  background.endDraw();
}
  
void drawTopView() 
{
  topView.beginDraw();
  topView.background(223, 175, 44);
  
  PVector ball = 
  new PVector(map(mover.location.x, -longueur_box / 2.0, longueur_box / 2.0, 0, topView.width), map(mover.location.z, -largeur_box / 2.0, largeur_box / 2.0, 0, topView.height));
  topView.fill(167, 103, 38);
  topView.ellipse(ball.x, ball.y, 18, 18);

  for (PVector vect : cylinder) 
  {
    PVector cylind = new PVector(map(vect.x, longueur_box / 2.0, -longueur_box / 2.0, 0, topView.width), map(vect.y, -largeur_box / 2.0, largeur_box / 2.0, 0, topView.height));

    topView.fill(0, 139, 0);
    topView.ellipse(cylind.x, cylind.y, 18, 18);
  }
  
  topView.endDraw();
}
  
void drawScoreBoard() 
{
  scoreBoard.beginDraw();
  scoreBoard.background(255);

  scoreBoard.fill(0);
  scoreBoard.text("Total Score:", 10, 20);
  scoreBoard.text((int) totalScore, 10, 35);
  scoreBoard.text("Velocity:", 10, 80);
  scoreBoard.text(mover.velocity.mag(), 10, 95);
  scoreBoard.text("Last Score:", 10, 160);
  scoreBoard.text(lastPoints, 10, 175);

  
  scoreBoard.endDraw();
}
  
void drawBarChart() 
{
 barChart.beginDraw();
 barChart.background(255);
 
 if(scoreEvolved) 
   {
    scoreEvolved = false;
    scores.add((int)totalScore);
   }
   
   float widthRec = 0.5 + 4.5*hScrollBar.getPos();
   float HeightRec = 5;
   
   for (int i = 0; i < scores.size(); ++i) 
   {
      int numberOfRec = Math.abs(scores.get(i))/10;
      for (int j = 0; j < numberOfRec; j+=1) 
      {
        if(scores.get(i) < 0) {barChart.fill(255, 0, 0);}
        else {barChart.fill(0, 0, 255);}
        barChart.rect(i*widthRec,barChart.height - j * HeightRec, widthRec, HeightRec);
      }
   }

 barChart.endDraw();
}
            
void mouseDragged() 
{
    
  if(!shift_on)
    {
    if (mouseY < 4 * height / 5.0) 
    {
      if (mouseX - pmouseX < 0) 
      {
        if (rotZ > -max_angle) 
        {
          rotZ -= d;
        }
      } 
      else if (mouseX - pmouseX > 0) 
      {
        if (rotZ < max_angle) 
        {
          rotZ += d;
        }
      }
         
      if (mouseY - pmouseY < 0) 
      {
        if (rotX < max_angle) 
        {
          rotX += d;
        }
      } 
      else if (mouseY - pmouseY > 0) 
      {
        if (rotX > -max_angle) 
        {
          rotX -= d;
        }
      }
    }
   }
}
           
void mouseWheel(MouseEvent event) 
{
  if(!shift_on)
  {
    if (event.getCount() < 0 && d < 15 * dd) 
    {
      d += dd;
    }
    else if (event.getCount() > 0 && d > 3 * dd) 
    {
      d -= dd;
    }
  }
}
        
void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == SHIFT) 
    {
       shift_on = true;
    } 
  }
}
    
void keyReleased()
{
  if (key == CODED)
  {
    if (keyCode == SHIFT) 
    {
      shift_on = false;
    } 
  }
}
  
void mouseClicked(MouseEvent e) 
{
  if (shift_on && e.getCount() == 1) 
  {
    boolean isCylinderHere = false;
    PVector ball = new PVector(mover.location.x, mover.location.y);
    PVector newCylinder = new PVector((width / 2.0 - mouseX), -(height / 2.0 - mouseY));

    for (int i = 0; i < cylinder.size(); ++i) 
    {
      if (PVector.dist(cylinder.get(i), newCylinder) < 2*cylinderBaseRadius) 
      {
        isCylinderHere = true;
      }

    }

  if (PVector.dist(ball, newCylinder) > cylinderBaseRadius + mover.rayon && !isCylinderHere) 
  {
    if (mouseX < longueur_box / 2.0 - cylinderBaseRadius + width/2 && mouseX > cylinderBaseRadius - longueur_box / 2.0 + width/2) 
    {
      if (mouseY < largeur_box / 2.0 - cylinderBaseRadius + height/2 && mouseY > cylinderBaseRadius - largeur_box / 2.0 + height/2) 
      {
        pushMatrix();
        
        rotateZ(PI / 2);
        cylinder.add(new PVector((width / 2.0 - mouseX), -(height / 2.0 - mouseY)));

        popMatrix();

      }

    }
  } 
 }
}
