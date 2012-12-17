import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.lang.reflect.*;
import static java.lang.System.out;
import java.util.Scanner;

public class T06FillUp extends TesterBase
{
    private static final String  fmt = "%24s: %s%n";

    public T06FillUp()
    {
	super();
    }

    public int test1()
    {
	if(addPictureP_M==null || explore_M==null)
	    {
		out.println("Your Album is missing the addPicture(Picture) or explore()");
		out.println("method(s).  Can't do test1.  Score=0");
		return 0;
	    }
	boolean crashed = false;
	Boolean ret1 = null;
	Boolean ret2 = null;
	try{
	    Album alb = new Album( 1 );
	    ret1 = (Boolean) addPictureP_M.invoke(alb,One150);
	    ret2 = (Boolean) addPictureP_M.invoke(alb,One150);
	}
	catch( Exception e )
	    {
		out.println("test1 crashed:");
		e.printStackTrace();
		crashed = true;
	    }
		
	int score;
	if( !crashed && ret1 && !ret2 )
	    {
		out.println("Handled filled array CORRECTLY-Accept");
		score = 20;
	    }
	else
	    {
		out.println("Didn't handle filled array right-Don't Accept");
		score = 0;
	    }
        return score;
    }



    public static void main(String[] a)
    {

	T06FillUp me = new T06FillUp();

	int nTests = 1;
	int scores[] = new int[nTests];


	//now do some testing!!!

	scores[0] = me.test1();

	me.printAndAddScores(scores,20);

    }


}
