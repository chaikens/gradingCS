import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.lang.reflect.*;
import static java.lang.System.out;
import java.util.Scanner;

public class PictureTester //Revised from Oracle's MethodSpy
{
    public static Scanner sc = new Scanner(System.in);

    public static int testChangeWhole()
    {

     Picture p1 = 
new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
	Picture p2 = new Picture(p1);

	out.println("Rate changeWhole[0-20]:");
	//Print the prompt FIRST so the test driver script
	//doesn't time out in waiting for our output and then
        //think we want input.
        p1.changeWhole( 0.4 );
        p1.show();
        p2.changeWhole( 0.9 );
	p2.show();
	//Putting the prompt print here forces the user to type
        //an Enter.
	int scin = sc.nextInt();
	p1.hide();
	p2.hide();
        return scin;
    }

    public static int testManipBoxUniformly(Method m)
    {
	out.println("testManipBoxUniformly: not imple. yet.");
	return 0;
    }

    public static int testManipBoxPatterned(Method m)
    {
	out.println("testManipBoxPatterned: not imple. yet.");
	return 0;
    }



  public static int testscribble(Method m)
    {
	Picture p = new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
	boolean returnsBoolean = false;
	if( m.getReturnType()==boolean.class ) 
	    returnsBoolean = true;
	double scale = 0.2;
	for( int i = 0; i < 5; i++ )
	    {
		for( int j = 0; j < 5; j++ )
		    {
			if(returnsBoolean)
			    {
				Object retval=null;				
				try {
				    retval =
				    m.invoke(p,
					     90*(j+1),70*(i+1),scale);
				}
				catch (InvocationTargetException | IllegalAccessException
				        e)
				    {
					System.out.println("invoking scribble failed.");
				    }
				

				System.out.println(retval);
			    }
			else
			    p.scribble(90*(j+1),70*(i+1),scale );

			scale *= 1.4;
		    }
	    }
	p.show();
	out.println("Rate scribble[0-20, +5 extra credit]:");
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
	    Class<?> c = Class.forName(args[0]);
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
		    scores[2]=testManipBoxUniformly(m);
		}
		if( m.getName().equals("ManipBoxPatterned") ) {
		    scores[3]=testManipBoxPatterned(m);
		}
	    }

        // production code should handle these exceptions more gracefully
	} catch (ClassNotFoundException x) {
	    x.printStackTrace();
	}

	out.print("Scores: ");
	for(int n : scores ) out.print("" + n + ", ");
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



