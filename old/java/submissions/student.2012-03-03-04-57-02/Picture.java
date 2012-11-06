import java.awt.*;
import java.awt.font.*;
import java.awt.geom.*;
import java.awt.image.BufferedImage;
import java.text.*;
import java.util.*;
import java.util.List; // resolves problem with java.awt.List and java.util.List

/**
 * A class that represents a picture.  This class inherits from 
 * SimplePicture and allows the student to add functionality to
 * the Picture class.  
 * 
 * Copyright Georgia Institute of Technology 2004-2005
 * @author Barbara Ericson ericson@cc.gatech.edu
 */
public class Picture extends SimplePicture 
{
  ///////////////////// constructors //////////////////////////////////
  
  /**
   * Constructor that takes no arguments 
   */
  public Picture ()
  {
    /* not needed but use it to show students the implicit call to super()
     * child constructors always call a parent constructor 
     */
    super();  
  }
  
  /**
   * Constructor that takes a file name and creates the picture 
   * @param fileName the name of the file to create the picture from
   */
  public Picture(String fileName)
  {
    // let the parent class handle this fileName
    super(fileName);
  }
  
  /**
   * Constructor that takes the width and height
   * @param width the width of the desired picture
   * @param height the height of the desired picture
   */
  public Picture(int width, int height)
  {
    // let the parent class handle this width and height
    super(width,height);
  }
  
  /**
   * Constructor that takes a picture and creates a 
   * copy of that picture
   */
  public Picture(Picture copyPicture)
  {
    // let the parent class do the copy
    super(copyPicture);
  }
  
  /**
   * Constructor that takes a buffered image
   * @param image the buffered image to use
   */
  public Picture(BufferedImage image)
  {
    super(image);
  }
  
  ////////////////////// methods ///////////////////////////////////////
  
  /**
   * Method to return a string with information about this picture.
   * @return a string with information about the picture such as fileName,
   * height and width.
   */
  public String toString()
  {
    String output = "Picture, filename " + getFileName() + 
      " height " + getHeight() 
      + " width " + getWidth();
    return output;
    
  }
  
  public void messUpColors()
  {
    System.out.println("Hello from messUpColors");
    Pixel[] pixelArray = this.getPixels();
    int index = 0;
    while( index < pixelArray.length )
    {
      Pixel pixel = pixelArray[index];
      int redInt = pixel.getRed();
      int greenInt = pixel.getGreen();
      int blueInt = pixel.getBlue();
      if( redInt > greenInt && redInt > blueInt )
      {
        pixel.setRed((int)(pixel.getRed()*(1.7)));
      }
      else if (greenInt > redInt && greenInt > blueInt)
      {
        pixel.setGreen((int)(pixel.getGreen()*(1.7)));
      }
      else if (blueInt > redInt && blueInt > greenInt)
      {
        pixel.setBlue((int)(pixel.getBlue()*(1.7)));
      }
      index++;
    }
  }
                            
 public void makeStoryBook()
 {
   Pixel[] pixelArray = this.getPixels();
    int index = 0;
    while( index < pixelArray.length )
    {
      Pixel pixel = pixelArray[index];
      int redInt = pixel.getRed();
      int greenInt = pixel.getGreen();
      int blueInt = pixel.getBlue();
      int avgInt = (redInt+blueInt+greenInt)/3;
      
      if( avgInt >= 190 || avgInt <= 100)
      {
        pixel.setColor(Color.black);
      }
    
      index++;
    }
 }
 
 public void solarize()
 {
   Pixel[] pixelArray = this.getPixels();
    int index = 0;
    while( index < pixelArray.length )
    {
      Pixel pixel = pixelArray[index];
      int redInt = pixel.getRed();
      int greenInt = pixel.getGreen();
      int blueInt = pixel.getBlue();
      int avgInt = (redInt+blueInt+greenInt)/3;
      
      if( avgInt >= 190 )
      {
        pixel.setColor(new Color(255-redInt,255-greenInt,255-blueInt));
      }
    
      index++;
    }
   
 }
 
 public void vignette()
 {
   double cX = this.getWidth()/2.0;
   System.out.println("Center x= " + cX );
   double cY = this.getHeight()/2.0;
   System.out.println("Center y= " + cY );
   double maxD = Math.sqrt( cX*cX + cY*cY);
   Pixel[] pixelArray = this.getPixels();
   int index = 0;
   while( index < pixelArray.length )
    {
      Pixel pixel = pixelArray[index];
      int redInt = pixel.getRed();
      int greenInt = pixel.getGreen();
      int blueInt = pixel.getBlue();
      int x = pixel.getX();
      int y = pixel.getY();
      double dist = Math.sqrt( (cX-x)*(cX-x) + (cY-y)*(cY-y));
      double rat = dist/maxD;
      pixel.setRed((int)(rat*255+ (1.0-rat)*pixel.getRed()));
      
      pixel.setGreen((int)(rat*255 + (1.0-rat)*pixel.getGreen()));
      pixel.setBlue((int)(rat*255 + (1.0-rat)*pixel.getBlue()));
     
    
      index++;
    }
 }
 
    public void vignette(int x1, int y1, int x2, int y2, Color color)
    {
	vignette(x1,y1,x2,y2,color,true);
    }

  public void vignette(int x1, int y1, int x2, int y2, Color color, boolean circular)
   {
     double cX = (x2+x1)/2.0;
     System.out.println("Center x= " + cX );
     double cY = (y2+y1)/2.0;
     System.out.println("Center y= " + cY );
     double maxD;
     if(!circular)
       maxD = Math.sqrt( (x1-cX)*(x1-cX) + (y1-cY)*(y1-cY));
     else
     {
       if((x2-x1)>(y2-y1))
         maxD = (y2-y1)/2.0;
       else
         maxD = (x2-x1)/2.0;
     }
     int redBorder = color.getRed();
     int blueBorder = color.getBlue();
     int greenBorder = color.getGreen();
     for( int x = x1; x <= x2; x++ )
      for( int y = y1; y <= y2; y++ )
      {
        Pixel pixel = this.getPixel(x,y);
        int redInt = pixel.getRed();
        int greenInt = pixel.getGreen();
        int blueInt = pixel.getBlue();
        double dist = Math.sqrt( (cX-x)*(cX-x) + (cY-y)*(cY-y));
        double rat = dist/maxD;
        if(rat <= 1.0)
        {
          pixel.setRed((int)(rat*redBorder+ (1.0-rat)*pixel.getRed()));
          pixel.setGreen((int)(rat*greenBorder + (1.0-rat)*pixel.getGreen()));
          pixel.setBlue((int)(rat*blueBorder + (1.0-rat)*pixel.getBlue()));
        }
    }
 }
 
  
  
  public static void main(String[] args) 
  {
    Scanner sc = new Scanner(System.in); 
    FileChooser.pickMediaPath();
     //String fileName = FileChooser.pickAFile();
     //Picture pictObj = new Picture(fileName);
     //pictObj.vignette();
     //pictObj.explore();
     Picture orig = new Picture(FileChooser.pickAFile());
     orig.write("/tmp/orig.jpg");
     orig.explore();
     System.out.print("x1 y1 x2 y2?");
     int x1 = sc.nextInt();
     int y1 = sc.nextInt();
     int x2 = sc.nextInt();
     int y2 = sc.nextInt();
     Picture nonCirc = new Picture(orig);
     Picture Circ = new Picture(orig);
     
     nonCirc.vignette(x1,y1,x2,y2,Color.white,false);
     Circ.vignette(x1,y1,x2,y2,Color.white,true);
     nonCirc.write("/tmp/nonCirc.jpg");
     Circ.write("/tmp/Circ.jpg");
     Circ.explore();
     nonCirc.explore();
  }
  
  
} // this } is the end of class Picture, put all new methods before this
 