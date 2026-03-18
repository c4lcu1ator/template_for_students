#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

struct Student {
    std::string imya;
    double ball;
    std::string predmet;

    Student(std::string i = "", double b = 0.0, std::string p = "") 
        : imya(i), ball(b), predmet(p) {}
};

class StudentManager {
private:
    std::vector<Student> students;

public:
    void add(const Student& s) {
        students.push_back(s);
        std::cout << "Добавлен: " << s.imya << std::endl;
    }

    void edit(const std::string& name, double new_ball) {
        for (auto& st : students) {
            if (st.imya == name) {
                st.ball = new_ball;
                std::cout << "Обновлён: " << name << ", новый балл: " << new_ball << std::endl;
                return;
            }
        }
        std::cout << "Студент не найден" << std::endl;
    }

    void remove(const std::string& name) {
        students.erase(std::remove_if(students.begin(), students.end(),
            [&name](const Student& s) { return s.imya == name; }),
            students.end());
        std::cout << "Удалён: " << name << std::endl;
    }

    void search(const std::string& query) {
        bool found = false;
        for (const auto& st : students) {
            if (st.imya.find(query) != std::string::npos) {
                std::cout << st.imya << " (" << st.ball << ", " << st.predmet << ")" << std::endl;
                found = true;
            }
        }
        if (!found) std::cout << "Не найдено" << std::endl;
    }
};

int main() {
    Student group[4] = {
        {"Анна", 4.8, ""},
        {"Борис", 4.2, ""},
        {"Катя", 4.9, ""},
        {"Дима", 4.6, ""}
    };
    std::cout << "Студенты >4.5:" << std::endl;
    for (int i = 0; i < 4; ++i) {
        if (group[i].ball > 4.5) {
            std::cout << group[i].imya << " (" << group[i].ball << ")" << std::endl;
        }
    }

    std::vector<Student> students = {
        {"Иван", 4.1, "Биология"},
        {"Мария", 4.7, "Биология"},
        {"Петр", 4.9, "Биология"},
        {"Ольга", 4.3, "Математика"},
        {"Сергей", 4.2, "Биология"}
    };
    Student max_bio;
    double max_ball = -1;
    for (const auto& st : students) {
        if (st.predmet == "Биология" && st.ball > max_ball) {
            max_ball = st.ball;
            max_bio = st;
        }
    }
    std::cout << "\nМакс по Биологии: " << max_bio.imya << " (" << max_bio.ball << ")" << std::endl;

    std::cout << "\n=== Система управления ===" << std::endl;
    StudentManager manager;
    manager.add(Student("Елена", 4.5, "Физика"));
    manager.add(Student("Алекс", 4.8, "Химия"));
    manager.edit("Елена", 4.9);
    manager.search("Ел");
    manager.remove("Алекс");
    manager.search("Ел");

    return 0;
}
