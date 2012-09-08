import java.util.Scanner;
class WholeUnitTest
{
    public static void main(String[]a)
    {
	Picture p = new Picture("/home/seth/black.jpg");
        p.vignette();
        p.show();
        Scanner sc = new Scanner(System.in);
        String n = sc.next();
	System.exit(0);
    }
}
