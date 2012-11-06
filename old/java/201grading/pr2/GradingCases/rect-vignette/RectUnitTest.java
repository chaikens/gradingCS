import java.util.Scanner;
class RectUnitTest
{
    public static void main(String[]a)
    {
	Picture p = new Picture("/home/seth/black.jpg");
        p.vignette(10,10, 300, 200, java.awt.Color.green);
        p.show();
        Scanner sc = new Scanner(System.in);
        String n = sc.next();
	System.exit(0);
    }
}
