#pragma once
#include <string>

enum class ClothesCategory
{
    Outerwear,   // верхняя одежда
    Shirt,
    Pants,
    Shoes,
    Accessories
};

class Clothes
{
private:
    ClothesCategory category;
    std::string     fullName;
    double          price;
    std::string     size;
    std::string     color;

public:
    Clothes();
    Clothes(ClothesCategory category,
            const std::string& fullName,
            double price,
            const std::string& size,
            const std::string& color);

    std::string getName() const;
    void        setName(const std::string& name);

    double      getPrice() const;
    void        setPrice(double value);

    ClothesCategory getCategory() const;
    void            setCategory(ClothesCategory c);

    std::string getSize()  const { return size; }
    void        setSize(const std::string& s) { size = s; }

    std::string getColor() const { return color; }
    void        setColor(const std::string& c) { color = c; }
};
