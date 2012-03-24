import java.util.Scanner;
class RectUnitTest
{
    public static void main(String[]a)
    {
	Picture p = 
 new Picture("/home/faculty1/sdc/public_html/CSI201/Spr12/Proj/Proj2/black.jpg");
        p.vignette(10,10, 300, 200, java.awt.Color.green);
        p.show();
        Scanner sc = new Scanner(System.in);
        String n = sc.next();
	System.exit(0);
    }
}
