#include <iostream>
#include <vector>
#include <algorithm>  // remove_if, sort, max_element
#include <string>

int main() {
    // Задание 1: Удалить отрицательные (remove_if + erase)
    std::cout << "=== Задание 1: Удаление отрицательных ===\n";
    std::vector<int> v1 = {5, -3, 8, -1, 0, 4, -7};
    std::cout << "До: ";
    for (int x : v1) std::cout << x << " ";
    std::cout << "\n";

    v1.erase(std::remove_if(v1.begin(), v1.end(), [](int x){ return x < 0; }), v1.end());

    std::cout << "После: ";
    for (int x : v1) std::cout << x << " ";  // 5 8 0 4
    std::cout << "\n\n";

    // Задание 2: Второй по величине
    std::cout << "=== Задание 2: Второй максимум ===\n";
    std::vector<int> v2 = {10, 5, 8, 12, 3, 12, 7};
    std::cout << "Vector: ";
    for (int x : v2) std::cout << x << " ";
    std::cout << "\n";

    // Сортируем descending, второй != max
    std::sort(v2.rbegin(), v2.rend());  // 12 12 10 8 7 5 3
    int max1 = v2[0];
    int second_max = -1;
    for (int i = 1; i < static_cast<int>(v2.size()); ++i) {
        if (v2[i] != max1) {
            second_max = v2[i];
            break;
        }
    }
    std::cout << "Максимум: " << max1 << ", второй: " << second_max << "\n\n";  // 12, 10

    // Задание 3: Сортировка строки по алфавиту
    std::cout << "=== Задание 3: Сортировка строки ===\n";
    std::string s = "programming";
    std::cout << "До: " << s << "\n";
    std::sort(s.begin(), s.end());
    std::cout << "После: " << s << "\n";  // aagimmnoprr

    return 0;
}
