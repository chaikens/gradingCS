import java.util.Scanner;
class changeWholeUnitTest
{
    public static void main(String[]a)
    {
	Picture p1 = 
 new Picture("/home/faculty1/sdc/public_html/CSI201/Fal12/Proj/Proj3/beach.jpg");
	Picture p2 = new Picture(p1);
        p1.changeWhole( 0.4 );
        p1.show();
        p2.changeWhole( 0.9 );
	p2.show();
        Scanner sc = new Scanner(System.in);
        String n = sc.next();
	System.exit(0);
    }
}
