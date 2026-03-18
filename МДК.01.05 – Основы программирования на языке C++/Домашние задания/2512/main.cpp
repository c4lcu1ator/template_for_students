#include <iostream>
#include <string>
#include <vector>
#include <algorithm>  // max_element

class Book {
private:
    std::string nazvanie;
    int stranits;

public:
    Book() : nazvanie(""), stranits(0) {}
    Book(std::string n, int s) : nazvanie(n), stranits(s) {}

    // Геттеры для доступа извне
    std::string getNazvanie() const { return nazvanie; }
    int getStranits() const { return stranits; }
};

class Student {
private:
    std::string imya;
    double sredniy_ball;

public:
    Student() : imya(""), sredniy_ball(0.0) {}
    Student(std::string i, double ball) : imya(i), sredniy_ball(ball) {}

    // Геттеры и сеттер
    std::string getImya() const { return imya; }
    double getBall() const { return sredniy_ball; }
    void setBall(double ball) { sredniy_ball = ball; }
};

// Задание 1
void printBook(const Book& s) {
    std::cout << "Книга: \"" << s.getNazvanie() << "\", страниц: " << s.getStranits() << std::endl;
}

// Задание 2
void increaseGrade(Student& s, double value) {
    s.setBall(s.getBall() + value);
}

// Задание 3: поиск max
Student findMaxStudent(const std::vector<Student>& students) {
    auto max_it = std::max_element(students.begin(), students.end(),
        [](const Student& a, const Student& b) {
            return a.getBall() < b.getBall();
        });
    return *max_it;
}

int main() {
    // Задание 1
    Book kniga("Война и мир", 1225);
    printBook(kniga);

    // Задание 2
    Student st("Иван", 4.2);
    increaseGrade(st, 0.5);
    std::cout << "Новый балл Ивана: " << st.getBall() << std::endl;

    // Задание 3
    std::vector<Student> gruppa = {
        Student("Анна", 4.8),
        Student("Борис", 4.1),
        Student("Катя", 4.9),
        Student("Дима", 3.9),
        Student("Елена", 4.7)
    };
    Student top = findMaxStudent(gruppa);
    std::cout << "Топ студент: " << top.getImya() << " (балл: " << top.getBall() << ")" << std::endl;

    return 0;
}
