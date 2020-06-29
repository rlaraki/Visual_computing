import java.util.Collections;
import gab.opencv.*;
import processing.video.*;

class ImageProcessing extends PApplet {

BlobDetection blobDetection;
QuadGraph quadGraph;
OpenCV opencv;
PVector rotation;

final float discretizationStepsPhi = 0.06f; 
final float discretizationStepsR = 2.5f; 
final int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
 
float[] tabSin = new float[phiDim];
float[] tabCos = new float[phiDim];
float ang = 0;
final float inverseR = 1.f / discretizationStepsR;

void settings()
{
  
  size(2400, 600);
  
  // pre-compute the sin and cos values
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) 
  {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }
  
}

void setup()
{

  rotation = new PVector(0, 0, 0);
 
  blobDetection = new BlobDetection();
  quadGraph = new QuadGraph();
  opencv = new OpenCV(this,100,100);

}

void draw() 
{
  PImage img2 = thresholdHSB(img, 45, 150, 40, 255, 55, 255);
  PImage img3 =  blobDetection.findConnectedComponents(img2, true);
  img2 = convolute(img3);
  img2 = scharr(img2);
  img2 = threshold(img2, 160);
  
  image(img, 0, 0);
  List<PVector> lines = hough(img2, 5);
  image(img2, 800, 0);
  image(img3, 1600, 0);
  
  
  List<PVector> points = quadGraph.findBestQuad(lines, img.width, img.height, img.width*img.height, 1000, false);

  for (int i = 0; i < points.size(); i++) 
  {
    fill((0 + i*60) % 255, (80 + i*60) % 255, (180 + i*60) % 255);
    ellipse(points.get(i).x, points.get(i).y, 32, 32);
  }
  
  //println(imagesEqual(imgcorr, img2));
  
  TwoDThreeD twoDThreeD = new TwoDThreeD(img.width, img.height, 0);
  
  List<PVector> homogeneousVectors = new ArrayList<PVector>();
  
  for (int i = 0; i < points.size(); ++i) 
  {
    PVector help = new PVector();
    help.x = points.get(i).x;
    help.y = points.get(i).y;
    help.z = 1;
    
    homogeneousVectors.add(help);
  }
  
  rotation = twoDThreeD.get3DRotations(homogeneousVectors);
  
}




PImage threshold(PImage img, int threshold)
{
  
  // create a new, initially transparent, 'result' image 
  PImage result = createImage(img.width, img.height, RGB);

  img.loadPixels();
  result.loadPixels();

  for(int i = 0; i < img.width * img.height; i++) 
  {
    if(brightness(img.pixels[i]) <= threshold)
    {
      result.pixels[i] = color(0,0,0);
    }
    else 
    {
      result.pixels[i]=color(255,255,255);
    }
  }
    
  result.updatePixels();
  return result;
}


PImage huetransform(PImage img , int min , int max)
{
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  
  for(int i = 0; i < img.width * img.height; i++) 
  {
      float hue = hue(img.pixels[i]);
    
      if(min<= hue && hue<=max)
      {
        result.pixels[i] = img.pixels[i];
      }
    
      else 
      {
        result.pixels[i] = color(0, 0, 0);
      }
    
   }
   
  result.updatePixels();
  return result;
}

PImage thresholdHSB(PImage img, int minH,int maxH,int minS,int maxS,int minB,int maxB)
{
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  
  for (int i = 0; i<img.width *img.height; ++i)
  {
      float hue = hue(img.pixels[i]);
      float saturation = saturation(img.pixels[i]);
      float brightness = brightness(img.pixels[i]);
    
      if(minH<=hue && hue<=maxH && minS <= saturation && saturation <= maxS && minB<=brightness &&brightness <=maxB)
      {
        result.pixels[i] = color(255,255,255);
      } 
      else 
      {
        result.pixels[i] = color(0,0,0);
      }
   }  
  
  return result;
  
}
  
boolean imagesEqual(PImage img1, PImage img2)
{
  if(img1.width != img2.width || img1.height != img2.height)
  return false;
  
  for(int i = 0; i < img1.width*img1.height ; i++)
  {          
      //assuming that all the three channels have the same value
      if(red(img1.pixels[i]) != red(img2.pixels[i])) return false;
  }
    
  return true; 
}
  
PImage convolute(PImage img)
{
  //float[][] kernel1 = { { 0, 0, 0 }, { 0, 2, 0 },
  //{ 0, 0, 0 }};

  //float[][] kernel2 = { { 0, 1, 0 }, { 1, 0, 1 },
  //{ 0, 1, 0 }};

  float[][] gaussianKernel = {{ 9, 12, 9 }, { 12, 15, 12 }, { 9, 12, 9 }};
  float normFactor = 99.f;
  float[][] kernel = gaussianKernel;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  // Clear the image
  
  for (int i = 0; i < img.width * img.height; ++i) 
  {
    result.pixels[i] = color(0);
  }

  img.loadPixels();
  result.loadPixels();


  for (int y = 1; y< img.height -1; ++y)
  {
    for(int x = 1; x< img.width -1; ++x)
    {
      float res = 0;
      int index1 = 0;
      int N = kernel.length;
      int N1 = kernel[0].length;
    
      for(int i = y-(N/2); i<= y+(N/2); ++i)
      {
        int index2 = 0;
        for(int j= x-(N1/2); j <= x+(N1/2); ++j)
        {
          int pix1 = Math.max(0, Math.min(img.height - 1, i))*img.width+Math.max(0, Math.min(img.width - 1, j)); 
          res += kernel[index1][index2]* brightness(img.pixels[pix1]);
          index2 +=1;
       }
       
       index1+=1;
      }
      result.pixels[(y*result.width)+ x ] = color((res/normFactor));
    }  
  }
  
  result.updatePixels();
  return result; 
}

PImage scharr(PImage img) 
{
  float[][] vKernel = 
  {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 }
  };

  float[][] hKernel = 
  {
    { 3, 10, 3}, 
    { 0, 0, 0}, 
    { -3, -10, -3 }
  };
  
  int N = vKernel.length;


  PImage result = createImage(img.width, img.height, ALPHA);
        // clear the image
  for (int i = 0; i < img.width * img.height; i++) 
  {
    result.pixels[i] = color(0);
  }
  
  float max=0;
  float[] buffer = new float[img.width * img.height];
        // *************************************

  for(int y = 0; y < img.height; ++y) 
  {
    for(int x = 0; x< img.width; ++x)
    {
      float sum_h = 0;
      float sum_v = 0;
      int index1 = 0;
      
      for(int i = y - (N/2); i <= y +(N/2); ++i)
      {
        int  index2 = 0;
        
        for(int j= x-(N/2); j <= x+(N/2); ++j)
        {
          int pix1 = Math.max(0, Math.min(img.height - 1, i)) * img.width + Math.max(0, Math.min(img.width - 1, j));
          sum_h += hKernel[index1][index2]*brightness(img.pixels[pix1]);
          sum_v += vKernel[index1][index2] * brightness(img.pixels[pix1]);
          index2 +=1;
        }
        index1+=1;
     }
     
     float sum = sqrt(pow(sum_h , 2) +pow(sum_v, 2));
     if(sum>max) 
     {
       max = sum;
     }
     
     buffer[y * img.width + x] = sum;
    } 
  
  }
       // *************************************
  for (int y = 2; y < img.height - 2; ++y) 
  { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; ++x) 
    { 
      // Skip left and right
      int val = (int) ((buffer[y * img.width + x] / max) * 255);
      result.pixels[y * img.width + x] = color(val);
    }
  }
  
  result.updatePixels();
  return result;
}

List<PVector> hough(PImage edgeImg, int nLines)
{
  int minVotes=50; 
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

  // dimensions of the accumulator
  //The max radius is the image diagonal, but it can be also negative
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width + edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);

  // our accumulator
  int[] accumulator = new int[phiDim * rDim];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) 
  {
    for (int x = 0; x < edgeImg.width; x++) 
    {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) 
      {
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator: r += rDim / 2
      
        for (int i = 0; i < phiDim; ++i) 
        {
          float r = Math.round(x* tabCos[i] + y * tabSin[i]);
          accumulator[(int) (i * rDim + (r + rDim/2))] += 1;
        }
      }
    }
  }
  
  int sizeRegion = 10;
  
  for (int i = 0; i < accumulator.length; ++i) 
  {
    int max = accumulator[i];
    if (max > minVotes) 
    {
      
      for (int j = Math.max(0, i - sizeRegion/2); j < Math.min(accumulator.length, i + sizeRegion/2); ++j) 
      {
        if (accumulator[j] > max) 
        {
          max = accumulator[j];
        }
      }
        
    if (max == accumulator[i]) 
    {
      bestCandidates.add(i);
    }
   }
  }
  
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  bestCandidates = new ArrayList<Integer>(bestCandidates.subList(0, Math.min(bestCandidates.size(), nLines)));
  
  
  ArrayList<PVector> lines=new ArrayList<PVector>();
  
  for (int idx = 0; idx < accumulator.length; idx++) 
  {
    if (bestCandidates.contains(idx)) 
    {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r,phi));
    }
  }
  
  drawLines(edgeImg, lines);
  
  return lines;
}

void drawLines(PImage edgeImg, ArrayList<PVector> lines) 
{
  for (int idx = 0; idx < lines.size(); idx++) 
  {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204,102,0);
    if (y0 > 0) 
    {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    }
    
    else 
    {
      if (x1 > 0) 
      {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      }
      
      else 
      {
        line(x2, y2, x3, y3);
      }
    }
  }
  
}

}
