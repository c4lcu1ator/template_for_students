#include <iostream>
#include <string>

class Student {
private:
    std::string name;
    int age;
    double grade;

public:
    void setData(const std::string& n, int a, double g) {
        name = n;
        age = a;
        grade = g;
    }

    void printlnInfo() const {
        std::cout << "Name: " << name
                  << ", Age: " << age
                  << ", Grade: " << grade << std::endl;
    }
};

class Calculator {
public:
    int add(int a, int b) {
        return a + b;
    }

    int sub(int a, int b) {
        return a - b;
    }

    int mul(int a, int b) {
        return a * b;
    }

    double div(double a, double b) {
        if (b == 0.0) {
            std::cout << "Error: division by zero" << std::endl;
            return 0.0;
        }
        return a / b;
    }
};

class Rectangle {
private:
    int width;
    int height;

public:
    void setSize(int w, int h) {
        width = w;
        height = h;
    }

    int area() const {
        return width * height;
    }

    int perimeter() const {
        return 2 * (width + height);
    }
};

int main() {
    Student s;
    s.setData("Ivan", 20, 4.5);
    s.printlnInfo();

    Calculator c;
    std::cout << "3 + 5 = " << c.add(3, 5) << std::endl;
    std::cout << "10 - 7 = " << c.sub(10, 7) << std::endl;
    std::cout << "4 * 6 = " << c.mul(4, 6) << std::endl;
    std::cout << "8 / 2 = " << c.div(8, 2) << std::endl;

    Rectangle r;
    r.setSize(5, 10);
    std::cout << "Area: " << r.area() << std::endl;
    std::cout << "Perimeter: " << r.perimeter() << std::endl;

    return 0;
}
