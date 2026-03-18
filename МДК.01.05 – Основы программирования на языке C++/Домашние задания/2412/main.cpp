#include <iostream>
#include <string>

struct Point {
    double x, y;
};

double rasstoyanie(const Point& p1, const Point& p2) {
    double dx = p1.x - p2.x;
    double dy = p1.y - p2.y;
    return dx*dx + dy*dy;  // квадрат расстояния без sqrt
}

struct Track {
    std::string imya;
    int dlitelnost;      // секунды
    int proslushaniya;
};

int main() {
    // Задание 1
    Point p1 = {0.0, 0.0};
    Point p2 = {3.0, 4.0};
    std::cout << "Расстояние между точками: " << rasstoyanie(p1, p2) << std::endl;

    // Задание 2
    Track trek;
    trek.imya = "Моя песня";
    trek.dlitelnost = 180;
    trek.proslushaniya = 150;
    std::cout << "Трек: " << trek.imya 
              << ", длительность: " << trek.dlitelnost << "с" 
              << ", прослушиваний: " << trek.proslushaniya << std::endl;

    return 0;
}
