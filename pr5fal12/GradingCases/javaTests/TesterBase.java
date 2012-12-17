import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.lang.reflect.*;
import static java.lang.System.out;
import java.util.Scanner;

public class TesterBase //Revised from Oracle's MethodSpy
{
    public Scanner sc = new Scanner(System.in);

    public String saveImagesPrefix = System.getenv("IMAGES_PREFIX");

    public Method addPictureP_M;
    public Method addPicturePW_M;
    public Method explore_M;

    public Picture One150;
    public Picture Two180;
    public Picture Three100;
    public Picture Three200;
    public Picture Four160;

    public String classNameToTest = "Album";

    public Class booleanClass = boolean.class;
    public Class voidClass = void.class;

    public TesterBase()
    {
	makePictures();
	getMethods();
    }

    public void makePictures()
    {
	String pbase = "/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj5/";
	One150 = new Picture( pbase + "One150.jpg");
	Two180 = new Picture( pbase + "Two180.jpg");
	Three100 = new Picture( pbase + "Three100.jpg");
	Three200 = new Picture( pbase + "Three200.jpg");
	Four160 = new Picture( pbase + "Four160.jpg");
    }

    public void getMethods()
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

    public void printAndAddScores(int[] scores, int base)
    {

	out.print("Scores: ");
	int isum=0;
	for(int n : scores ) 
	    {
		out.print("" + n + ", ");
		isum = isum + n;
	    }
	if(isum == base)
	    {
		out.println("TA: Type C-A Enter to ACCEPT!");
	    }
	else
	    {
		float sum = isum/((float) base);
		out.println("TA: Type C-G Enter and this number " + sum);
	    }
	out.println("Goodbye!");
    }

}

