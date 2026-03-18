#include <iostream>
#include <string>
using namespace std;

class Book {
private:
    string nazvanie;
    int stranits;

public:
    // Конструктор по умолчанию
    Book() : nazvanie(""), stranits(0) {}

    // Параметризованный конструктор
    Book(string n, int s) : nazvanie(n), stranits(s) {}

    // Метод вывода информации
    void vyvod() {
        cout << "Название: " << nazvanie << ", страниц: " << stranits << endl;
    }
};
