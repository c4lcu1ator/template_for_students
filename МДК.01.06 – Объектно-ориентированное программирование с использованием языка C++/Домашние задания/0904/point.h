#pragma once
#include <iostream>

class Point
{
private:
    double x;
    double y;

public:
    Point();
    Point(double x, double y);

    double getX() const;
    double getY() const;

    void setX(double value);
    void setY(double value);

    Point operator+(const Point& other) const;
    Point operator-(const Point& other) const;

    bool operator==(const Point& other) const;

    friend std::ostream& operator<<(std::ostream& os, const Point& p);
};
