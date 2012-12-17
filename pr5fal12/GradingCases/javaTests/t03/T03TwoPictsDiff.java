import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.lang.reflect.*;
import static java.lang.System.out;
import java.util.Scanner;

public class T03TwoPictsDiff extends TesterBase
{
    private static final String  fmt = "%24s: %s%n";

    public T03TwoPictsDiff()
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
	try{
	    Album alb = new Album( 5 );
	    addPictureP_M.invoke(alb,One150);
	    addPictureP_M.invoke(alb,Two180);
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



    public static void main(String[] a)
    {

	T03TwoPictsDiff me = new T03TwoPictsDiff();

	int nTests = 1;
	int scores[] = new int[nTests];


	//now do some testing!!!

	scores[0] = me.test1();

	me.printAndAddScores(scores,20);

    }


}
