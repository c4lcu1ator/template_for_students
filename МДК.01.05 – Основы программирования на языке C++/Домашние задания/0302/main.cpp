#include <iostream>
#include <vector>
#include <algorithm>  // count_if, remove_if, all_of, min_element
#include <string>
#include <numeric>    // для count_if (C++17)

int main() {
    // Задание 1: Количество отрицательных
    std::cout << "=== Задание 1: Количество отрицательных ===\n";
    std::vector<int> v1 = {5, -3, 8, -1, 0, 4, -7, -2};
    int neg_count = std::count_if(v1.begin(), v1.end(), [](int x){ return x < 0; });
    std::cout << "Vector: ";
    for (int x : v1) std::cout << x << " ";
    std::cout << "\nОтрицательных: " << neg_count << "\n\n";  // 4

    // Задание 2: Удалить чётные
    std::cout << "=== Задание 2: Удалить чётные ===\n";
    std::vector<int> v2 = {1, 2, 3, 4, 5, 6, 7, 8};
    std::cout << "До: ";
    for (int x : v2) std::cout << x << " ";
    std::cout << "\n";

    v2.erase(std::remove_if(v2.begin(), v2.end(), [](int x){ return x % 2 == 0; }), v2.end());

    std::cout << "После: ";
    for (int x : v2) std::cout << x << " ";  // 1 3 5 7
    std::cout << "\n\n";

    // Задание 3: Все положительные?
    std::cout << "=== Задание 3: Все положительные? ===\n";
    std::vector<int> v3 = {1, 2, 3, 4, 5};
    bool all_positive = std::all_of(v3.begin(), v3.end(), [](int x){ return x > 0; });
    std::cout << "Vector: ";
    for (int x : v3) std::cout << x << " ";
    std::cout << "\nВсе >0: " << (all_positive ? "Да" : "Нет") << "\n\n";

    // Задание 4: Min → 0
    std::cout << "=== Задание 4: Min заменить на 0 ===\n";
    std::vector<int> v4 = {10, 5, -2, 8, 1};
    std::cout << "До: ";
    for (int x : v4) std::cout << x << " ";
    std::cout << "\n";

    auto min_it = std::min_element(v4.begin(), v4.end());
    *min_it = 0;

    std::cout << "После: ";
    for (int x : v4) std::cout << x << " ";  // 10 5 0 8 1
    std::cout << "\n\n";

    // Задание 5: Строка обратный алфавит
    std::cout << "=== Задание 5: Строка обратный алфавит ===\n";
    std::string s = "programming";
    std::cout << "До: " << s << "\n";
    std::sort(s.rbegin(), s.rend());  // reverse iterator
    std::cout << "После: " << s << "\n";  // rrpomnimgaa

    return 0;
}
