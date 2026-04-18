#include "Point.h"

Point::Point()
    : x(0.0), y(0.0)
{
}

Point::Point(double x, double y)
    : x(x), y(y)
{
}

double Point::getX() const
{
    return x;
}

double Point::getY() const
{
    return y;
}

void Point::setX(double value)
{
    x = value;
}

void Point::setY(double value)
{
    y = value;
}

// Задание 1: сложение координат
Point Point::operator+(const Point& other) const
{
    return Point(x + other.x, y + other.y);
}

// Задание 1: вычитание координат
Point Point::operator-(const Point& other) const
{
    return Point(x - other.x, y - other.y);
}

// Задание 2: проверка равенства точек
bool Point::operator==(const Point& other) const
{
    return x == other.x && y == other.y;
}

// Задание 3: вывод точки в поток
std::ostream& operator<<(std::ostream& os, const Point& p)
{
    os << "(" << p.x << ", " << p.y << ")";
    return os;
}
