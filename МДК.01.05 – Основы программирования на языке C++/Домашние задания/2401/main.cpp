#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

enum class Category { Food, Drink, Electronics, Clothing };

struct Product {
    std::string name;
    Category category;
    std::string unit;  // кг, л, шт
    double price;

    Product(std::string n, Category c, std::string u, double p) 
        : name(n), category(c), unit(u), price(p) {}
};

std::string catToString(Category c) {
    switch (c) {
        case Category::Food: return "Еда";
        case Category::Drink: return "Напитки";
        case Category::Electronics: return "Электроника";
        case Category::Clothing: return "Одежда";
        default: return "Неизвестно";
    }
}

class Shop {
private:
    std::vector<Product> catalog;
    std::vector<std::pair<Product, int>> cart;  // товар + количество

public:
    Shop() {
        // Список товаров
        catalog.emplace_back("Яблоки", Category::Food, "кг", 150.0);
        catalog.emplace_back("Хлеб", Category::Food, "шт", 80.0);
        catalog.emplace_back("Кола", Category::Drink, "л", 100.0);
        catalog.emplace_back("Вода", Category::Drink, "л", 50.0);
        catalog.emplace_back("Телефон", Category::Electronics, "шт", 30000.0);
        catalog.emplace_back("Футболка", Category::Clothing, "шт", 800.0);
    }

    void printCatalog() {
        std::cout << "\n=== КАТАЛОГ ТОВАРОВ ===\n";
        std::cout << std::left << std::setw(20) << "Название"
                  << std::setw(12) << "Категория"
                  << std::setw(8) << "Ед.изм."
                  << std::setw(10) << "Цена" << std::endl;
        for (const auto& p : catalog) {
            std::cout << std::left << std::setw(20) << p.name
                      << std::setw(12) << catToString(p.category)
                      << std::setw(8) << p.unit
                      << std::setw(10) << std::fixed << std::setprecision(2) << p.price << " руб" << std::endl;
        }
    }

    void addToCart() {
        printCatalog();
        std::cout << "Выберите товар (номер 0-" << catalog.size()-1 << "): ";
        int idx;
        std::cin >> idx;
        if (idx < 0 || idx >= static_cast<int>(catalog.size())) {
            std::cout << "Неверный номер!\n";
            return;
        }
        std::cout << "Количество: ";
        int qty;
        std::cin >> qty;
        cart.emplace_back(catalog[idx], qty);
        std::cout << "Добавлено в корзину!\n";
    }

    void printCart() {
        std::cout << "\n=== КОРЗИНА ===\n";
        double total = 0;
        for (const auto& item : cart) {
            double sum = item.first.price * item.second;
            total += sum;
            std::cout << item.first.name << " x" << item.second << " (" << item.first.unit << ") = "
                      << std::fixed << std::setprecision(2) << sum << " руб\n";
        }
        std::cout << "ИТОГО: " << std::fixed << std::setprecision(2) << total << " руб\n";
    }

    void clearCart() {
        cart.clear();
        std::cout << "Корзина очищена!\n";
    }
};

int main() {
    Shop shop;
    int choice;

    while (true) {
        std::cout << "\n=== МАГАЗИН ===\n";
        std::cout << "1. Показать товары\n";
        std::cout << "2. Добавить в корзину\n";
        std::cout << "3. Показать корзину\n";
        std::cout << "4. Очистить корзину\n";
        std::cout << "0. Выход\n";
        std::cout << "Выбор: ";
        std::cin >> choice;

        if (choice == 0) break;
        else if (choice == 1) shop.printCatalog();
        else if (choice == 2) shop.addToCart();
        else if (choice == 3) shop.printCart();
        else if (choice == 4) shop.clearCart();
        else std::cout << "Неверный пункт!\n";
    }

    return 0;
}
