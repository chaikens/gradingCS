import java.util.Scanner;
class scribbleUnitTest
{
    public static void main(String[]a)
    {
	Picture p = new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
        double scale = 0.2;
	for( int i = 0; i < 5; i++ )
	    {
		for( int j = 0; j < 5; j++ )
		    {
			System.out.println(
			p.scribble(90*(j+1),70*(i+1),scale ));
			scale *= 1.4;
		    }
	    }
	p.show();
        Scanner sc = new Scanner(System.in);
        String n = sc.next();
	System.exit(0);
    }
}
