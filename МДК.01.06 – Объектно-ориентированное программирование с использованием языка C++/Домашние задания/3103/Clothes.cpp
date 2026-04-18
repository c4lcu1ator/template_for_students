#include "Clothes.h"

Clothes::Clothes()
    : category(ClothesCategory::Shirt),
      fullName(""),
      price(0.0),
      size("M"),
      color("black")
{
}

Clothes::Clothes(ClothesCategory category,
                 const std::string& fullName,
                 double price,
                 const std::string& size,
                 const std::string& color)
    : category(category),
      fullName(fullName),
      price(price),
      size(size),
      color(color)
{
}

std::string Clothes::getName() const
{
    return fullName;
}

void Clothes::setName(const std::string& name)
{
    fullName = name;
}

double Clothes::getPrice() const
{
    return price;
}

void Clothes::setPrice(double value)
{
    price = value;
}

ClothesCategory Clothes::getCategory() const
{
    return category;
}

void Clothes::setCategory(ClothesCategory c)
{
    category = c;
}
