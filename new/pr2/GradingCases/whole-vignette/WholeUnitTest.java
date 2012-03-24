import java.util.Scanner;
class WholeUnitTest
{
    public static void main(String[]a)
    {
	Picture p = new Picture("/home/faculty1/sdc/public_html/CSI201/Spr12/Proj/Proj2/vignetteTest.jpg");
        p.vignette();
        p.show();
        Scanner sc = new Scanner(System.in);
        String n = sc.next();
	System.exit(0);
    }
}
