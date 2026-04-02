using System;

public class Order
{
    private static int nextId = 1;
    public int OrderId { get; private set; }

    public Order()
    {
        OrderId = nextId++;
    }

    public void DisplayInfo()
    {
        Console.WriteLine($"Order #{OrderId}");
    }
}

public class DatabaseConnector
{
    public static string connectionString;

    static DatabaseConnector()
    {
        connectionString = "Server=localhost;DB=Test";
        Console.WriteLine("Static constructor called");
    }

    public DatabaseConnector()
    {
        Console.WriteLine("Instance created");
    }

    public void Connect()
    {
        Console.WriteLine($"Connecting with: {connectionString}");
    }
}

class Program
{
    static void Main()
    {
        Console.WriteLine("Задача 1:");
        Order order1 = new Order();
        order1.DisplayInfo();

        Order order2 = new Order();
        order2.DisplayInfo();

        Order order3 = new Order();
        order3.DisplayInfo();

        Order order4 = new Order();
        order4.DisplayInfo();

        Console.WriteLine("\nЗадача 2:");
        DatabaseConnector db1 = new DatabaseConnector();
        db1.Connect();

        DatabaseConnector db2 = new DatabaseConnector();
        db2.Connect();
    }
}
