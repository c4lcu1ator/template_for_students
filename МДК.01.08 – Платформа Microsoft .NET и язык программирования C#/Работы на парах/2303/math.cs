using System;

public class Circle
{
    public static readonly double PI = 3.14159;
    public double Radius;

    public Circle(double radius)
    {
        Radius = radius;
    }

    public double GetArea()
    {
        return PI * Radius * Radius;
    }
}

class Program
{
    static void Main()
    {
        Circle circle1 = new Circle(5.0);
        Circle circle2 = new Circle(3.0);
        
        Console.WriteLine(circle1.GetArea()); // 78.53975
        Console.WriteLine(circle2.GetArea()); // 28.27431
    }
}
