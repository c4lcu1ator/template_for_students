#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

struct Engine {
    std::string model;
    int power;  // л.с.

    Engine(std::string m = "", int p = 0) : model(m), power(p) {}
};

struct Car {
    std::string brand;
    int year;
    Engine engine;

    Car(std::string b = "", int y = 0, std::string em = "", int ep = 0) 
        : brand(b), year(y), engine(em, ep) {}
};

struct Author {
    std::string name;
    std::string country;

    Author(std::string n = "", std::string c = "") : name(n), country(c) {}
};

struct Book {
    std::string title;
    int year;
    Author author;

    Book(std::string t = "", int y = 0, std::string an = "", std::string ac = "") 
        : title(t), year(y), author(an, ac) {}
};

struct Student {
    std::string name;
    std::string city;

    Student(std::string n = "", std::string c = "") : name(n), city(c) {}
};

// Задание 3
void printStudentsInCity(const std::vector<Student>& students, const std::string& city) {
    std::cout << "\nСтуденты в " << city << ":" << std::endl;
    for (const auto& s : students) {
        if (s.city == city) {
            std::cout << s.name << std::endl;
        }
    }
}

int main() {
    // Задание 1
    std::cout << "=== Задание 1: Car ===" << std::endl;
    Car toyota("Toyota", 2020, "V6", 250);
    std::cout << "Машина: " << toyota.brand << " (" << toyota.year << " г.), "
              << "Двигатель: " << toyota.engine.model << ", " << toyota.engine.power << " л.с." << std::endl;

    // Задание 2
    std::cout << "\n=== Задание 2: СПИСОК КНИГ ===" << std::endl;
    std::vector<Book> library = {
        Book("Война и мир", 1869, "Лев Толстой", "Россия"),
        Book("1984", 1949, "Джордж Оруэлл", "Великобритания"),
        Book("Гарри Поттер", 1997, "Дж. К. Роулинг", "Великобритания")
    };
    for (const auto& b : library) {
        std::cout << "- \"" << b.title << "\" (" << b.year << "), автор: " 
                  << b.author.name << " (" << b.author.country << ")" << std::endl;
    }

    // Задание 3
    std::vector<Student> students = {
        Student("Иван", "Москва"),
        Student("Анна", "СПб"),
        Student("Петр", "Москва"),
        Student("Мария", "Екатеринбург")
    };
    printStudentsInCity(students, "Москва");

    return 0;
}
