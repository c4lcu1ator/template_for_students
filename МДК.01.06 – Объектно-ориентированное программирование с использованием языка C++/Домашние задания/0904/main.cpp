#include <iostream>
#include "Point.h"

int main()
{
    Point a(1.0, 2.0);
    Point b(3.5, -1.0);

    Point sum  = a + b; // вызывает Point::operator+
    Point diff = a - b; // вызывает Point::operator-

    std::cout << "a = "    << a    << '\n';
    std::cout << "b = "    << b    << '\n';
    std::cout << "a + b = "<< sum  << '\n';
    std::cout << "a - b = "<< diff << '\n';

    Point c(1.0, 2.0);
    if (a == c) {
        std::cout << "a и c равны\n";
    } else {
        std::cout << "a и c не равны\n";
    }

    return 0;
}
