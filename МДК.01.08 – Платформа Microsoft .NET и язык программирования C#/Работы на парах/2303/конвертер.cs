using System;

public static class CurrencyConverter
{
    public static double usdToRubRate = 90.0;

    public static void SetRate(double rate)
    {
        usdToRubRate = rate;
    }

    public static double ConvertUsdToRub(double usd)
    {
        return usd * usdToRubRate;
    }

    public static double ConvertRubToUsd(double rub)
    {
        return rub / usdToRubRate;
    }
}

class Program
{
    static void Main()
    {
        Console.WriteLine(CurrencyConverter.ConvertUsdToRub(10)); // 900
        CurrencyConverter.SetRate(95.0);
        Console.WriteLine(CurrencyConverter.ConvertRubToUsd(950)); // 10
    }
}
