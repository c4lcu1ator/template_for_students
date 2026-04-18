#include <iostream>
#include "Array.h"
#include "Count.h"

int main()
{
    Array arr;
    for (int i = 0; i < arr.size(); ++i)
        arr[i] = (i + 1) * 10;

    std::cout << "Array: ";
    arr.print();

    try {
        std::cout << "arr[2] = " << arr[2] << '\n';
        std::cout << "Попытка доступа к arr[10]...\n";
        std::cout << arr[10] << '\n';
    } catch (const std::out_of_range& ex) {
        std::cout << "Ошибка: " << ex.what() << '\n';
    }

    Count c(5);
    std::cout << "\nНачальное значение c = " << c << '\n';

    std::cout << "Префикс ++c: " << ++c << " (текущее c = " << c << ")\n";
    std::cout << "Постфикс c++: " << c++ << " (после c = " << c << ")\n";

    std::cout << "Префикс --c: " << --c << " (текущее c = " << c << ")\n";
    std::cout << "Постфикс c--: " << c-- << " (после c = " << c << ")\n";

    return 0;
}
