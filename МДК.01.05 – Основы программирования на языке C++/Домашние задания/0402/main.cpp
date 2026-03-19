#include <iostream>
#include <vector>
#include <algorithm>  // count_if, find_if, sort
#include <iterator>   // distance

int main() {
    // Задание 1: count_if >10
    std::cout << "=== Задание 1: >10 ===\n";
    std::vector<int> v1 = {5, 12, 8, 15, 3, 20, 9, 11};
    std::cout << "Vector: ";
    for (int x : v1) std::cout << x << " ";
    std::cout << "\n";

    int count_gt10 = std::count_if(v1.begin(), v1.end(), [](int x){ return x > 10; });
    std::cout << "Больше 10: " << count_gt10 << "\n\n";  // 4

    // Задание 2: find_if первое отрицательное
    std::cout << "=== Задание 2: Первое отрицательное ===\n";
    std::vector<int> v2 = {5, 8, -3, 12, -1, 7};
    std::cout << "Vector: ";
    for (int x : v2) std::cout << x << " ";
    std::cout << "\n";

    auto it = std::find_if(v2.begin(), v2.end(), [](int x){ return x < 0; });
    if (it != v2.end()) {
        std::cout << "Первое отрицательное: " << *it << " (индекс: " 
                  << std::distance(v2.begin(), it) << ")\n";
    } else {
        std::cout << "Отрицательных нет\n";
    }
    std::cout << "\n";

    // Задание 3: sort по убыванию с лямбдой
    std::cout << "=== Задание 3: Sort убывание ===\n";
    std::vector<int> v3 = {5, 12, 8, 15, 3, 20, 9, 11};
    std::cout << "До: ";
    for (int x : v3) std::cout << x << " ";
    std::cout << "\n";

    std::sort(v3.begin(), v3.end(), [](int a, int b){ return a > b; });

    std::cout << "После: ";
    for (int x : v3) std::cout << x << " ";  // 20 15 12 11 9 8 5 3
    std::cout << "\n";

    return 0;
}
