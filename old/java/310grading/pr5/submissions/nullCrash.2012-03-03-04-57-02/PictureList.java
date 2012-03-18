import java.util.Scanner; //For asking the user yes or no.
class PictureList 
{
  private PositionedSceneElement refToFirstElement;
  private PositionedSceneElement refToLastElement;
  private PositionedSceneElement cursor;
  private int nPictures;
  private Picture copy;
  private int cursorWidth = 15;
  private int cursorChangeWidth = 5;

  public PictureList()
  {
    this.refToFirstElement = null;
    this.refToLastElement = null;
    this.cursor = null;
    this.copy = null;
    this.nPictures = 0;
  }
  
  public void getImagesFromUser()
  { /* You write! */ 
    FileChooser.pickMediaPath();
    Scanner sc = new Scanner(System.in);
    System.out.println("Another picture? Type Y if so.");
    String response = sc.next();
    while(response.equals("Y"))
    {
      Picture p = new Picture(FileChooser.pickAFile());
      insertOnePictureAtEnd( p );
      System.out.println("Another picture? Type Y if so.");
      response = sc.next();
    } 
  }

  private void insertOnePictureAt(Picture x, PositionedSceneElement e)
  {
    PositionedSceneElement myNewNode = new PositionedSceneElement(x);
    if(e == null)
    {
      myNewNode.setNext(refToFirstElement);
      myNewNode.setPrev(null);
      if(refToFirstElement!=null)
        refToFirstElement.setPrev(myNewNode);
      else
        refToLastElement = myNewNode;
      refToFirstElement = myNewNode;
    }
    else
    {
      myNewNode.setNext(e.getNext());
      myNewNode.setPrev(e);
      if(e.getNext()!=null)
        e.getNext().setPrev(myNewNode);
      else
        refToLastElement = myNewNode;
      e.setNext(myNewNode);
    }
    nPictures++;
  }
  public void insertOnePictureAtEnd(Picture x)
  { 
    PositionedSceneElement myNewNode = new PositionedSceneElement(x);
    if(refToFirstElement == null)
    {
      /* You write! The empty list case is special.*/
      refToFirstElement = myNewNode;
      refToLastElement = myNewNode;
      myNewNode.setNext(null);
      myNewNode.setPrev(null);
    }
    else
    {
      /* You write! */
      refToLastElement.setNext(myNewNode);
      myNewNode.setPrev(refToLastElement);
      refToLastElement = myNewNode;
    }
    nPictures++;
  }
  
  private PositionedSceneElement removeAndReturnNodeAfter(PositionedSceneElement x)
  {
    PositionedSceneElement target;
    if( x == null )
    {
      if( refToFirstElement == null )
      {
        return null;
      }
      else
      {
        target = refToFirstElement;
        refToFirstElement = refToFirstElement.getNext();
        if(refToFirstElement == null) refToLastElement = null;
        else refToFirstElement.setPrev(null);
      }
    }
    else
    {
      target = x.getNext();
      if(target == null ) return null;
      x.setNext(target.getNext());
      if(x.getNext()==null) refToLastElement = x;
      else x.getNext().setPrev(x);
    }
    if(target!=null)
    {
      target.setNext(null);
      target.setPrev(null);
      nPictures--;
    }
    return target;
  }
  
  

  public int totalWidth()
  //It's public so you can test it from main().
  { /* You write! */
    PositionedSceneElement p = refToFirstElement;
    int width = 0;
    while(p!=null)
    {
      width = width  + p.getPicture().getWidth();
      p = p.getNext();
    }
    return width;
  }
  public int maxHeight()
  //It's public so you can test it from main().
  { /* You write! */ 
    PositionedSceneElement p = refToFirstElement;
    int height = 0;
    while(p!=null)
    {
      if(p.getPicture().getHeight() > height )
        height =   + p.getPicture().getHeight();
      p = p.getNext();
    }
    return height;
  }
 
  private void drawHorizCursor(Picture p, int xUL, int yUL, int length)
  {
   int changeCounter = 0;
   java.awt.Color color0 = java.awt.Color.BLACK;
   java.awt.Color color1 = java.awt.Color.YELLOW;
   java.awt.Color color = color0;
   for(int x = xUL; x < length + xUL; x++)
   { 
    changeCounter++;
    if(changeCounter > cursorChangeWidth)
    {
     changeCounter = 0;
     if(color==color0) color = color1;
     else color = color0; 
    }  
    for(int y = yUL; y < yUL+cursorWidth; y++)
     p.getPixel(x,y).setColor(color);
   }
  }
  private void drawVertCursor(Picture p, int xUL, int yUL, int height)
  {
   int changeCounter = 0;
   java.awt.Color color0 = java.awt.Color.BLACK;
   java.awt.Color color1 = java.awt.Color.YELLOW;
   java.awt.Color color = color0;
   for(int y = yUL; y < yUL+height; y++)
    {
     changeCounter++;
     if(changeCounter > cursorChangeWidth)
     {
     changeCounter = 0;
     if(color==color0) color = color1;
     else color = color0; 
     } 
     for(int x = xUL; x < xUL+cursorWidth; x++)
     p.getPixel(x,y).setColor(color);
    }
  }
  
  
  public Picture makeTopJustifiedCombo()
  { /* You write! */
    int width = totalWidth();
    int height = maxHeight();
    Picture top = new Picture(width,height);
    PositionedSceneElement p = refToFirstElement;
    int xpos = 0;
    while(p != null)
    {
      copyFromToWhere(p.getPicture(), top, xpos, 0);
      xpos = xpos + p.getPicture().getWidth();
      p = p.getNext();
    }
    return top;
  }
  public Picture makeCenteredCombo()
  { /* You write! */
    int width = totalWidth() + cursorWidth*2;
    int maxHeightPixOnly = maxHeight();
    int height = maxHeightPixOnly + cursorWidth*2;
    //if( width == 0 ) width = 1;
    //if( height == 0) height = 1;
    Picture cen = new Picture(width,height);
    PositionedSceneElement p = refToFirstElement;
    PositionedSceneElement prev = null;
    int xpos = 0;
    while(p != null)
    {
      if(prev == cursor)
      {//draw cursor around p's Picture
       int pictHeight = p.getPicture().getHeight();
       int pictWidth = p.getPicture().getWidth();
       int yULPict = cursorWidth+
         (maxHeightPixOnly-pictHeight)/2;
       int xULPict = cursorWidth + xpos;
          copyFromToWhere(p.getPicture(), cen,xULPict,yULPict);
          drawHorizCursor(cen,xULPict-cursorWidth,yULPict-cursorWidth,
            pictWidth+cursorWidth*2);
          drawHorizCursor(cen,xULPict-cursorWidth,yULPict+pictHeight,
          pictWidth+cursorWidth*2);
          drawVertCursor(cen,xULPict-cursorWidth,yULPict,pictHeight);
          drawVertCursor(cen,xULPict+pictWidth,yULPict,pictHeight);
          xpos = xpos + p.getPicture().getWidth() + cursorWidth*2;
       
      }
      else
      {//don't draw cursor  
       copyFromToWhere(p.getPicture(), cen, xpos, 
                          cursorWidth+
                          (maxHeightPixOnly-p.getPicture().getHeight())/2);
       xpos = xpos + p.getPicture().getWidth();
      }
      prev = p;
      p = p.getNext();
    }
    if(prev == cursor)
    {
     
     drawHorizCursor(cen,xpos,0,cursorWidth*2);
     drawHorizCursor(cen,xpos,height-cursorWidth,cursorWidth*2);
     drawVertCursor(cen,xpos,cursorWidth,height-2*cursorWidth);
     drawVertCursor(cen,xpos+cursorWidth,cursorWidth,height-2*cursorWidth);
    }
    return cen;
   }
  public Picture makeBottomJustifiedCombo()
  { /* You write! */
    int width = totalWidth();
    int height = maxHeight();
    Picture bot = new Picture(width,height);
    PositionedSceneElement p = refToFirstElement;
    int xpos = 0;
    while(p != null)
    {
      copyFromToWhere(p.getPicture(), bot, xpos, 
                      (height-p.getPicture().getHeight())
                     );
      xpos = xpos + p.getPicture().getWidth();
      p = p.getNext();
    
    }  
    return bot;
  }
  public static void copyFromToWhere( Picture fromPict, Picture toPict,
                                     int xWhere, int yWhere)
  {    
    for(int x=0; x < fromPict.getWidth(); x++)
    {
      for(int y=0; y < fromPict.getHeight(); y++)
      {
        toPict
          .getPixel(x+xWhere,y+yWhere)
          .setRed(fromPict.getPixel(x,y).getRed());
        toPict
          .getPixel(x+xWhere,y+yWhere)
          .setGreen(fromPict.getPixel(x,y).getGreen());
        toPict
          .getPixel(x+xWhere,y+yWhere)
          .setBlue(fromPict.getPixel(x,y).getBlue());
      }
    }
  }
  public boolean homeCmd()
  {
   if(cursor == null)
    return false;  //DIDN'T MOVE THE CURSOR!
   else
   {
    cursor = null;
    return true;
   }
  }
  public boolean forwardCmd()
  {
   if(cursor == null) cursor = refToFirstElement;
   else cursor = cursor.getNext(); 
   return true;
  }
  public boolean backwardCmd()
  {
    if(cursor == null) cursor = refToLastElement;
    else cursor = cursor.getPrev();
    return true;
  }
  public boolean copyCmd()
  {
      Picture pict=null;
      if(cursor == null)
      {
        if(refToFirstElement == null)
        {
          System.out.println("NO PICTURES CAN'T COPY!");
        }
        else
          pict = refToFirstElement.getPicture();
      }
      else 
      {
       PositionedSceneElement node = cursor.getNext();
          if(node == null)
          {
           System.out.println("CURSOR AFTER LAST PICTURE: CAN'T COPY!");
          }
          else pict = node.getPicture();
      }
      if(pict!=null)
      {
        copy = pict;
      }
      return false; //Copy doen't change cursor.
  }
  public boolean pasteCmd()
  {
      if(copy == null)
      {
        System.out.println("Nothing copied or cut to paste! Try again.");
        return false;
      }
      else
      {
        Picture p = copy;
        insertOnePictureAt(p,cursor);
        return true;
      }
  }
  public boolean cutCmd()
  {
      PositionedSceneElement temp;
      temp = removeAndReturnNodeAfter(cursor);
      if(temp == null)
      {
        System.out.println("Nothing to cut! Try again.");
        return false;
      }
      else
      {
        copy = temp.getPicture();
        return true;
      } 
  }
  public boolean cutEndCmd()
  {
    if(refToLastElement!=null)
    {
      cursor = refToLastElement.getPrev();
      return cutCmd();
    }
    else
    {
       System.out.println("Nothing to cut! Try again.");
       return false;
    }
  }
  public boolean pasteEndCmd()
  {
    if(copy==null)
    {
      System.out.println("Clipboard empty, can't paste. Try again.");
      return false;
    }
    cursor = refToLastElement;
    return pasteCmd();
  }
  
  public Picture reDoResult(Picture x)
  {
   x.hide();
   x = makeCenteredCombo();
   x.show();
   return x;
  }
  public void commandLoop()
  {
    Scanner sc = new Scanner(System.in);
    boolean done = false;
    Picture combo = makeCenteredCombo();
    combo.show();
    while(!done)
    { 
      boolean success;
      System.out.print("Phase One and Three Commands:\n"
    		             +"CM - cut middle and move it to the clipboard\n"
                         +"PE - paste clipboard to end\n"
                         +"CE - cut end and move it to clipboard\n"
                         +"XX - stop running this program\n"
                         +"\nPhase Two Commands:\n"
                         +"MF - move cursor forward\n"
                         +"MB - move cursor backward\n"
                         +"\nPhase Four Commands:\n"                         		
                         +"CC - cut at the cursor\n"
                         +"PC - paste at the cursor\n"
                         );
      if(cursor!=null)
      {
    	  if(cursor.getNext()!=null)
    	  System.out.println(cursor.getNext().getPicture());
    	  else
    	  System.out.println("No Picture");
      }
      else
      {
    	  if(refToFirstElement!=null)
    		  System.out.println(refToFirstElement.getPicture());
    	  else
    		  System.out.println("No Picture");
      }
      //System.out.println("You have " + nPictures + " images in your collage.\n");
      System.out.print("Command(CM PE CE XX MF MB CC PC):");
      String cmd = sc.next();
      
      if(cmd.equals("CM"))
      {
        if(nPictures==0)
        {
          System.out.println("Nothing to cut.  Try again.");
          success = false;
        }
        else if( nPictures < 3 )
        {
          cursor = null;
          success = cutCmd();
        }
        else
        {
          cursor = refToFirstElement;
          for(int i = 1; i < (nPictures-1)/2; i++)
            cursor = cursor.getNext();
          success = cutCmd();
        }
      }
                 
      else if(cmd.equals("CE")) 
        success = cutEndCmd();
      else if(cmd.equals("PE"))
        success = pasteEndCmd();
      
      else if(cmd.equals("MF"))
       success = forwardCmd();
      else if(cmd.equals("MB"))
       success = backwardCmd();
      else if(cmd.equals("PC"))
       success = pasteCmd();
      else if(cmd.equals("CC"))
       success = cutCmd();
      else if(cmd.equals("XX")) 
      {
       done = true;
       success = false;
      }
      else 
      {
        System.out.println("Misspelled command. Try again.");
        success = false;
      } 
      if(success && !done)
       combo = reDoResult(combo);
    }
    System.out.println("The command loop has finished.");
  }
    
    
  public static void main(String[] a)
  {
    PictureList myPL = new PictureList();
    myPL = null;
    myPL.getImagesFromUser();
    //Picture centered = myPL.makeCenteredCombo();
    //centered.show();
    //Picture bottom = myPL.makeBottomJustifiedCombo();
    //bottom.show();
    //Picture top = myPL.makeTopJustifiedCombo();
    //top.show();
    myPL.commandLoop();
    System.exit(0);
  }
}

