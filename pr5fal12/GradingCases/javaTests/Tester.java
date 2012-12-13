import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.lang.reflect.*;
import static java.lang.System.out;
import java.util.Scanner;

public class Tester //Revised from Oracle's MethodSpy
{
    public static Scanner sc = new Scanner(System.in);

    public static String saveImagesPrefix = System.getenv("IMAGES_PREFIX");

    public static Method addPictureP_M;
    public static Method addPicturePW_M;
    public static Method explore_M;

    public static Picture P[];
    public static String classNameToTest = "Album";

    public static Class booleanClass = boolean.class;
    public static Class voidClass = void.class;

    public static void makePictures()
    {
	P = new Picture[4];
	String pbase = "/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj5/";
	P[0] = new Picture( pbase + "One.jpg");
	P[1] = new Picture( pbase + "Two.jpg");
	P[2] = new Picture( pbase + "Three.jpg");
	P[3] = new Picture( pbase + "Four.jpg");
    }

    public static void getMethods()
    {
	try {
	    Class<?> c = Class.forName(classNameToTest);
	    Method[] allMethods = c.getDeclaredMethods();
	    for (Method m : allMethods) {
		//		if (!m.getName().equals(args[1])) {
		//  continue;
		//}
		out.format("%s%n", m.toGenericString());
		if( m.getName().equalsIgnoreCase("explore") ) {
		    explore_M=m;
		}
		if( m.getName().equalsIgnoreCase("addPicture")
		    ||
		    m.getName().equalsIgnoreCase("add"))
		{

		    Class<?>[] parray = m.getParameterTypes();
		    if(parray.length == 1
		       &&
		       parray[0].getName().equals("Picture"))
		    {
			addPictureP_M = m;
		    }
		    else if(parray.length == 2
			    &&
			    parray[0].getName().equals("Picture")
			    &&
			    parray[1].getName().equals("int"))
		    {
			addPicturePW_M = m;		       
		    }
		}
	    }

        // production code should handle these exceptions more gracefully
	} catch (ClassNotFoundException x) {
	    x.printStackTrace();
	}

    }

    private static final String  fmt = "%24s: %s%n";

    public static void main(String[] a)
    {

	getMethods();
	makePictures();

	int nTests = 1;
	int scores[] = new int[nTests];


	//now do some testing!!!

	scores[0] = test1();

	out.print("Scores: ");
	int isum=0;
	for(int n : scores ) 
	    {
		out.print("" + n + ", ");
		isum = isum + n;
	    }
	if(isum == 90)
	    {
		out.println("TA: Type C-A Enter to ACCEPT!");
	    }
	else
	    {
		float sum = isum/((float) 20);
		out.println("TA: Type C-G Enter and this number " + sum);
	    }
	out.println("Goodbye!");
    }

    public static int test1()
    {
	if(addPictureP_M==null || explore_M==null)
	    {
		out.println("Your Album is missing the addPicture(Picture) or explore()");
		out.println("method(s).  Can't do test1.  Score=0");
		return 0;
	    }
	boolean crashed = false;
	try{
	    Album alb = new Album( 4 );
	    addPictureP_M.invoke(alb,P[0]);
	    addPictureP_M.invoke(alb,P[1]);
	    addPictureP_M.invoke(alb,P[2]);	
	    explore_M.invoke(alb);
	}
	catch( Exception e )
	    {
		out.println("test1 crashed:");
		e.printStackTrace();
		crashed = true;
	    }
		
	int score = 0;
	if( crashed )
	    {
		out.println("Score is 0.");
	    }
	else
	    {
		out.println("Rate test1[0-20]:");
		score = sc.nextInt();
	    }
        return score;
    }




}





