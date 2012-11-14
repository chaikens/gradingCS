import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.lang.reflect.*;
import static java.lang.System.out;
import java.util.Scanner;

public class PictureTester //Revised from Oracle's MethodSpy
{
    public static Scanner sc = new Scanner(System.in);

    public static String saveImagesPrefix = System.getenv("IMAGES_PREFIX");

    public static int testChangeWhole()
    {
     Picture p1 = 
new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
	Picture p2 = new Picture(p1);
	double amt1 = 0.4;
	double amt2 = 0.9;
	out.println("Testing changeWhole with amounts " + amt1 + " and " + amt2);
        p1.changeWhole( amt1 );
        p1.show();
        p2.changeWhole( amt2);
	p2.show();
	out.println("Rate changeWhole[0-20]:");
	int scin = sc.nextInt();
	p1.hide();
	p2.hide();
	if(saveImagesPrefix != null)
	    {
		String Samt1 = (""+amt1).replace(".","r");
		String Samt2 = (""+amt2).replace(".","r");
		p1.write(saveImagesPrefix + "whole" + Samt1 + ".bmp");
		p2.write(saveImagesPrefix + "whole" + Samt2 + ".bmp");
	    }
        return scin;
    }

    public static Object maniP(Method m, Picture p, 
			     int xU, int yU,
			     int xL, int yL, double amount)
    {
	//boolean returnsBoolean = (m.getReturnType()==boolean.class);
	if(true /*returnsBoolean*/)
	{
	    Object retval=null;				
	    try {
		retval = m.invoke(p,xU,yU,xL,yL,amount);
            }
	    catch (InvocationTargetException | IllegalAccessException e){
		System.out.println("invoke in manip failed.");
		e.printStackTrace();
	    }
	    System.out.println(retval);
	    return retval;
	}
	return null;
	//else
	//  m.invoke(p,xU,yU,xL,yL,amount);
    }


    public static int testManipBox(Method m)
    {
	out.print("Method's return type is:");
	out.println(m.getReturnType());


	Picture porig = new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
	Picture p = new Picture( porig );
	double amount = 0.1;
	out.println("Testing manip amount 0.1 to " + amount*5*2);

	int hstrip = p.getWidth()/10-1;
	int vstrip = p.getHeight()/7-1;
	for(int i = 0; i < 3; i++)
	    for(int j = 0; j < 2; j++)
		{
		    double camt = amount*(2*i+1)*(j+1);
		    out.println("amount=" + camt); 
		    maniP(m,p,
		      hstrip+3*i*hstrip,
		      vstrip+3*j*vstrip,
		      3*hstrip+3*i*hstrip,
		      3*vstrip+3*j*vstrip,
		      camt);
		}
	p.show();
	out.println("Enter another starting amount value, or 0.0 to stop:");
	while( (amount = sc.nextDouble()) != 0.0)
	    {
		p.hide();
		p = new Picture( porig );
		for(int i = 0; i < 3; i++)
		    for(int j = 0; j < 2; j++)
			{
			    double camt = amount*(2*i+1)*(j+1);
			    out.println("amount=" + camt); 
			    maniP(m,p, 
			      hstrip+3*i*hstrip,
			      vstrip+3*j*vstrip,
			      3*hstrip+3*i*hstrip,
			      3*vstrip+3*j*vstrip,
			      camt);
			}
		p.show();
	    }
	int scin = -1;
	while( scin > 20 || scin < 0)
	    {
		out.println("Rate manip [0-20]:");
		try {scin = sc.nextInt();}
		catch(Exception e){out.println("rating input failed");}
	    }
	if(saveImagesPrefix!=null)
	    p.write(saveImagesPrefix + m.getName()+".bmp");
	p.hide();
	
        return scin;
    }

    public static Object scribble(Method m, Picture p, double scale)
    {
	int xM = p.getWidth()/2;
	int yM = p.getHeight()/2;
	boolean returnsBoolean = (m.getReturnType()==boolean.class);
	if(returnsBoolean)
	{
	    Object retval=null;				
	    try {
		retval = m.invoke(p,xM,yM,scale);
            }
	    catch (InvocationTargetException | IllegalAccessException e){
		System.out.println("invoking scribble failed.");
		e.printStackTrace();
	    }
	    System.out.println(retval);
	    return retval;
	}
	else
	    p.scribble(xM,yM,scale);
	return null;
    }
	    




  public static int testscribble(Method m)
    {
	Picture porig = new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
	Picture p = new Picture( porig );
	out.println("We'll first test scribble with scale=1.0");
	double scale = 1.0;
	scribble(m, p, scale);

	p.show();
	if(saveImagesPrefix != null)
	    {
		String Sscale = (""+scale).replace(".","r");
		p.write(saveImagesPrefix + "scribble" + Sscale + ".bmp");
	    }
	out.println("Enter another scale value, or 0.0 to stop:");
	while( (scale = sc.nextDouble()) != 0.0)
	    {
		p.hide();
		p = new Picture( porig );
		scribble(m, p, scale);
		p.show();
		if(saveImagesPrefix != null)
		    {
			String Sscale = (""+scale).replace(".","r");
			p.write(saveImagesPrefix + "scribble" + Sscale + ".bmp");
		    }
		out.println("When scribble returns true, try to up the scale to make it return false!");
		out.println("Enter another scale value, or 0 to stop:");
	    }
	out.println("Rate scribble[0-20, +10 extra credit if going out of bounds is detected]:");
	int scin = sc.nextInt();
	p.hide();
        return scin;
    }







    private static final String  fmt = "%24s: %s%n";


    // for the morbidly curious
    <E extends RuntimeException> void genericThrow() throws E {}

    public static void main(String... args) {
	//	Picture p;
	Class booleanClass = boolean.class;
	Class voidClass = void.class;
	String parts[] = {"changeWhole", "scribble", 
			  "ManipBoxUniformly", "ManipBoxPatterned"};
	int scores[] = {0,0,0,0};

	try {
	    Class<?> c = Class.forName("Picture");
	    Method[] allMethods = c.getDeclaredMethods();
	    for (Method m : allMethods) {
		//		if (!m.getName().equals(args[1])) {
		//  continue;
		//}
		out.format("%s%n", m.toGenericString());
		if( m.getName().equals("changeWhole") ) {
		    scores[0]=testChangeWhole();
		}
		if( m.getName().equals("scribble") ) {
		    scores[1]=testscribble(m);
		}
		if( m.getName().equals("ManipBoxUniformly") ) {
		    scores[2]=testManipBox(m);
		}
		if( m.getName().equals("ManipBoxPatterned") ) {
		    scores[3]=testManipBox(m);
		}
	    }

        // production code should handle these exceptions more gracefully
	} catch (ClassNotFoundException x) {
	    x.printStackTrace();
	}

	out.print("Scores: ");
	int isum=0;
	for(int n : scores ) 
	    {
		out.print("" + n + ", ");
		isum = isum + n;
	    }
	if(isum == 90)
	    {
		out.println("TA: Type C-A to ACCEPT!");
	    }
	else
	    {
		float sum = isum/((float) 90);
		out.println("TA: Type C-G and number " + sum);
	    }
	out.println("Goodbye!");

   /*    Picture p;
    public boolean getPicture()
    {
	p = new Picture(800,800);
	return p!=null;
    }
    public void printMethods
    {

    }
    public static void main(String... args)
    {
	PictureTester myT = new PictureTester();

    }
   
*/

}










}



