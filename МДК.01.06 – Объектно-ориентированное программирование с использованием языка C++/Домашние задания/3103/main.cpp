#include <iostream>
#include "Clothes.h"

std::string categoryToString(ClothesCategory c)
{
    switch (c)
    {
    case ClothesCategory::Outerwear:   return "Outerwear";
    case ClothesCategory::Shirt:       return "Shirt";
    case ClothesCategory::Pants:       return "Pants";
    case ClothesCategory::Shoes:       return "Shoes";
    case ClothesCategory::Accessories: return "Accessories";
    }
    return "Unknown";
}

int main()
{
    Clothes jacket(
        ClothesCategory::Outerwear,
        "Зимняя куртка",
        5999.0,
        "L",
        "синий"
    );

    std::cout << "Название: "   << jacket.getName()        << '\n';
    std::cout << "Категория: "  << categoryToString(jacket.getCategory()) << '\n';
    std::cout << "Цена: "       << jacket.getPrice()       << " руб.\n";
    std::cout << "Размер: "     << jacket.getSize()        << '\n';
    std::cout << "Цвет: "       << jacket.getColor()       << "\n\n";

    jacket.setPrice(5499.0);
    jacket.setName("Зимняя куртка (со скидкой)");
    jacket.setCategory(ClothesCategory::Outerwear);

    std::cout << "После изменения:\n";
    std::cout << "Название: "   << jacket.getName()        << '\n';
    std::cout << "Категория: "  << categoryToString(jacket.getCategory()) << '\n';
    std::cout << "Цена: "       << jacket.getPrice()       << " руб.\n";

    return 0;
}
