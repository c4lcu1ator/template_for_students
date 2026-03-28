using System;

class Rectangle
{
    // Публичные поля
    public double width;
    public double height;

    // Метод для вычисления площади
    public double GetArea()
    {
        return width * height;
    }

    // Метод для вычисления периметра
    public double GetPerimeter()
    {
        return 2 * (width + height);
    }
}

class Program
{
    static void Main()
    {
        // Прямоугольник 1
        Rectangle rect1 = new Rectangle();
        rect1.width = 10;
        rect1.height = 5;

        double area1 = rect1.GetArea();
        double perimeter1 = rect1.GetPerimeter();

        Console.WriteLine("Прямоугольник 1:");
        Console.WriteLine("- Ширина: " + rect1.width);
        Console.WriteLine("- Высота: " + rect1.height);
        Console.WriteLine("- Площадь: " + area1);
        Console.WriteLine("- Периметр: " + perimeter1);
        Console.WriteLine();

        // Прямоугольник 2
        Rectangle rect2 = new Rectangle();
        rect2.width = 7.5;
        rect2.height = 3.2;

        double area2 = rect2.GetArea();
        double perimeter2 = rect2.GetPerimeter();

        Console.WriteLine("Прямоугольник 2:");
        Console.WriteLine("- Ширина: " + rect2.width);
        Console.WriteLine("- Высота: " + rect2.height);
        Console.WriteLine("- Площадь: " + area2);
        Console.WriteLine("- Периметр: " + perimeter2);

        Console.ReadLine();
    }
}
