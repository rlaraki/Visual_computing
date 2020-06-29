import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;


class BlobDetection {
    
PImage findConnectedComponents(PImage input, boolean onlyBiggest)
{
  
  // First pass: label the pixels and store labels' equivalences
  
  int [] labels= new int [input.width*input.height];
  List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
  int currentLabel=1;
  input.loadPixels();
  for (int y = 0; y < input.height; ++y) 
  {
    for (int x = 0; x < input.width; ++x)  
    {
      if (input.pixels[y * input.width + x] == color(255, 255, 255)) 
      {
            
        if (x == 0 && y == 0) //pixel on the top left corner
        {
          labels[y * input.width + x] = currentLabel;
          TreeSet<Integer> a = new TreeSet();
          a.add(currentLabel);
          labelsEquivalences.add(a);
          ++currentLabel; 
        }
        
        else if (y == 0) //first line
        {
          int labelPx1 = labels[y * input.width + x - 1];
        
          if (labelPx1 == Integer.MAX_VALUE) 
          {
            labels[y * input.width + x] = currentLabel;
            TreeSet<Integer> a = new TreeSet();
            a.add(currentLabel);
            labelsEquivalences.add(a);
        
            ++currentLabel;
          }
          else 
          {
            labels[y * input.width + x] = labelPx1;
          }
        }  
        
        else if (x == 0) //first column
        {
          int labelPx3 = labels[(y-1) * input.width +x];
          int labelPx4 = labels[(y-1) * input.width + x + 1];
        
          if (labelPx3 == labelPx4) 
          {
              if (labelPx3 == Integer.MAX_VALUE) 
              {
                labels[y * input.width +x] = currentLabel;
              
                TreeSet<Integer> a = new TreeSet();
                a.add(currentLabel);
                labelsEquivalences.add(a);
              
                ++currentLabel;
              } 
              else 
              {
                labels[y * input.width + x] = labelPx3;
              }
          }
          
          else 
          {
            int minLabel = Math.min(labelPx3, labelPx4);
            labels[y * input.width + x] = minLabel;
          
            TreeSet<Integer> a = new TreeSet();
            if (labelPx3 != Integer.MAX_VALUE) {
            a.addAll(labelsEquivalences.get(labelPx3-1));}
            if (labelPx4 != Integer.MAX_VALUE) {
            a.addAll(labelsEquivalences.get(labelPx4-1));}
            if (labelPx3 != Integer.MAX_VALUE) {
            labelsEquivalences.set(labelPx3 - 1, a);}
            if (labelPx4 != Integer.MAX_VALUE) {
            labelsEquivalences.set(labelPx4 - 1, a);}
          }
        }
                
        else if (x == input.width -1) //last column
        {  
          int labelPx1 = labels[y * input.width + x - 1];
          int labelPx2 = labels[(y-1) * input.width + x - 1];
          int labelPx3 = labels[(y-1) * input.width + x];
        
          if (labelPx1 == labelPx2 && labelPx1 == labelPx3) 
          {
              if (labelPx1 == Integer.MAX_VALUE) 
              {
                labels[y * input.width +x] = currentLabel;
              
                TreeSet<Integer> a = new TreeSet();
                a.add(currentLabel);
                labelsEquivalences.add(a);
              
                ++currentLabel;}
              else 
              {
                labels[y * input.width + x] = labelPx1;
              }   
              
          }
          
          else 
          {
            int minLabel = Math.min(labelPx1, Math.min(labelPx2, labelPx3));
            labels[y * input.width + x] = minLabel;
          
            TreeSet<Integer> a = new TreeSet();
            if (labelPx1 != Integer.MAX_VALUE) 
            {
              a.addAll(labelsEquivalences.get(labelPx1-1));}
          
              if (labelPx2 != Integer.MAX_VALUE) {
              a.addAll(labelsEquivalences.get(labelPx2-1));}
              if(labelPx3 != Integer.MAX_VALUE) {
              a.addAll(labelsEquivalences.get(labelPx3-1));}
              if (labelPx1 != Integer.MAX_VALUE) {
              labelsEquivalences.set(labelPx1 - 1, a);}
              if (labelPx2 != Integer.MAX_VALUE) {
              labelsEquivalences.set(labelPx2 - 1, a);}
              if(labelPx3 != Integer.MAX_VALUE) {
              labelsEquivalences.set(labelPx3 - 1, a);
              }
           }
        }
        
        else //all other pixels
        {
          int labelPx1 = labels[y * input.width + x - 1];
          int labelPx2 = labels[(y-1) * input.width + x - 1];
          int labelPx3 = labels[(y-1) * input.width + x];
          int labelPx4 = labels[(y-1) * input.width + x +1];
        
          if (labelPx1 == labelPx2 && labelPx1 == labelPx3 && labelPx1 == labelPx4) 
          {
              if (labelPx1 == Integer.MAX_VALUE) 
              {
                labels[y * input.width +x] = currentLabel;
              
                TreeSet<Integer> a = new TreeSet();
                a.add(currentLabel);
                labelsEquivalences.add(a);
              
                ++currentLabel;
              } 
              else 
              {
                labels[y * input.width + x] = labelPx1;
              }
          }
        
          else 
          {
            int minLabel = Math.min(labelPx1, Math.min(labelPx2, Math.min(labelPx3, labelPx4)));
            labels[y * input.width + x] = minLabel;
          
            TreeSet<Integer> a = new TreeSet();
            if (labelPx1 != Integer.MAX_VALUE) {
            a.addAll(labelsEquivalences.get(labelPx1-1));}
            if (labelPx2 != Integer.MAX_VALUE) {
            a.addAll(labelsEquivalences.get(labelPx2-1));}
            if(labelPx3 != Integer.MAX_VALUE) {
            a.addAll(labelsEquivalences.get(labelPx3-1));}
            if(labelPx4 != Integer.MAX_VALUE) {
            a.addAll(labelsEquivalences.get(labelPx4-1));}
            if (labelPx1 != Integer.MAX_VALUE) {
            labelsEquivalences.set(labelPx1 - 1, a);}
            if (labelPx2 != Integer.MAX_VALUE) {
            labelsEquivalences.set(labelPx2 - 1, a);}
            if(labelPx3 != Integer.MAX_VALUE) {
            labelsEquivalences.set(labelPx3 - 1, a);}
            if (labelPx4 != Integer.MAX_VALUE) {
            labelsEquivalences.set(labelPx4 - 1, a);}
          } 
        }
      }
      
      else 
      {
        labels[y * input.width + x] = Integer.MAX_VALUE;
      } 
      
    }
  }
    
  // TODO!
  // Second pass: re-label the pixels by their equivalent class
  // if onlyBiggest==true, count the number of pixels for each label
  
  int max = 0;
  int labelWithMostPixels = 0;
  int[] pixelsByLabels = new int[labelsEquivalences.size()];
  
  for (int i = 0; i < labels.length; ++i) 
  {
    if (labels[i] != Integer.MAX_VALUE) 
    {
    labels[i] = labelsEquivalences.get(labels[i]-1).first();
      
      if(onlyBiggest) 
      {
        ++pixelsByLabels[labels[i]-1];
      
        if (pixelsByLabels[labels[i]-1] > max) 
        {
          max = pixelsByLabels[labels[i]-1];
          labelWithMostPixels = labels[i];
        }
      }
    }
  
  }
  
  
  // TODO!
  // Finally,
  // if onlyBiggest==false, output an image with each blob colored in one uniform color
  // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
  // TODO!
 
  PImage retour = createImage(input.width, input.height, RGB);
  
  for (int i = 0; i < input.width * input.height; ++i) 
  {
    if (labels[i] == Integer.MAX_VALUE) 
    {
      retour.pixels[i] = color (0);
    }
    
    else 
    {
      if (onlyBiggest) 
      {
        if (labels[i] == labelWithMostPixels)
        {
          retour.pixels[i] = color(255);
        }
        else 
        {
          retour.pixels[i] = color(0);
        }
      }
      
    else 
    {
      int pixColor = 255 * labels[i] / currentLabel;
      retour.pixels[i] = color (pixColor % 255, pixColor % 255 + 85, pixColor %255+ 170);
    }
   }
  }
  
  retour.updatePixels();
       return retour;   
  }
}
