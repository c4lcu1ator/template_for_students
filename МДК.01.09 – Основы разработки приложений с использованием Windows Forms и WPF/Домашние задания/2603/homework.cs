/*
#include <iostream>
#include <vector>
#include <string>
using namespace std;

// ===== Задание 1. Квадрат из символа =====
void printSquare(int side, char symbol) {
    for (int i = 0; i < side; ++i) {
        for (int j = 0; j < side; ++j) {
            cout << symbol << " ";
        }
        cout << endl;
    }
}

// ===== Задание 2. Число-палиндром =====
bool isPalindrome(int num) {
    int original = num;
    int reversed = 0;

    while (num > 0) {
        reversed = reversed * 10 + num % 10;
        num /= 10;
    }

    return original == reversed;
}

// ===== Задание 3. Фильтрация массива =====
vector<int> filterArray(const vector<int>& originalArray, const vector<int>& filterArray) {
    vector<int> result;

    for (int elem : originalArray) {
        bool found = false;
        for (int filterElem : filterArray) {
            if (elem == filterElem) {
                found = true;
                break;
            }
        }
        if (!found) {
            result.push_back(elem);
        }
    }

    return result;
}

// ===== Задание 4. Класс «Веб-сайт» =====
class Website {
private:
    string name;
    string path;
    string description;
    string ip;

public:
    void input() {
        cout << "Название сайта: ";    getline(cin, name);
        cout << "Путь к сайту: ";      getline(cin, path);
        cout << "Описание сайта: ";    getline(cin, description);
        cout << "IP-адрес сайта: ";   getline(cin, ip);
    }

    void output() {
        cout << "Название: " << name << endl;
        cout << "Путь: " << path << endl;
        cout << "Описание: " << description << endl;
        cout << "IP: " << ip << endl;
    }

    string getName()                 { return name; }
    void setName(const string& n)    { name = n; }

    string getPath()                 { return path; }
    void setPath(const string& p)    { path = p; }

    string getDescription()          { return description; }
    void setDescription(const string& d) { description = d; }

    string getIp()                   { return ip; }
    void setIp(const string& i)      { ip = i; }
};

// ===== Задание 5. Класс «Журнал» =====
class Journal {
private:
    string name;
    int foundingYear;
    string description;
    string phone;
    string email;

public:
    void input() {
        cout << "Название журнала: ";        getline(cin, name);
        cout << "Год основания: ";           cin >> foundingYear;
        cin.ignore();
        cout << "Описание журнала: ";        getline(cin, description);
        cout << "Телефон: ";                 getline(cin, phone);
        cout << "E-mail: ";                  getline(cin, email);
    }

    void output() {
        cout << "Название: " << name << endl;
        cout << "Год основания: " << foundingYear << endl;
        cout << "Описание: " << description << endl;
        cout << "Телефон: " << phone << endl;
        cout << "E-mail: " << email << endl;
    }

    string getName()                 { return name; }
    void setName(const string& n)    { name = n; }

    int getYear()                    { return foundingYear; }
    void setYear(int y)              { foundingYear = y; }

    string getDescription()          { return description; }
    void setDescription(const string& d) { description = d; }

    string getPhone()                { return phone; }
    void setPhone(const string& p)   { phone = p; }

    string getEmail()                { return email; }
    void setEmail(const string& e)   { email = e; }
};

// ===== Задание 6. Класс «Магазин» =====
class Shop {
private:
    string name;
    string address;
    string description;
    string phone;
    string email;

public:
    void input() {
        cout << "Название магазина: ";           getline(cin, name);
        cout << "Адрес: ";                       getline(cin, address);
        cout << "Описание профиля магазина: ";   getline(cin, description);
        cout << "Телефон: ";                    getline(cin, phone);
        cout << "E-mail: ";                     getline(cin, email);
    }

    void output() {
        cout << "Название: " << name << endl;
        cout << "Адрес: " << address << endl;
        cout << "Описание: " << description << endl;
        cout << "Телефон: " << phone << endl;
        cout << "E-mail: " << email << endl;
    }

    string getName()                 { return name; }
    void setName(const string& n)    { name = n; }

    string getAddress()              { return address; }
    void setAddress(const string& a) { address = a; }

    string getDescription()          { return description; }
    void setDescription(const string& d) { description = d; }

    string getPhone()                { return phone; }
    void setPhone(const string& p)   { phone = p; }

    string getEmail()                { return email; }
    void setEmail(const string& e)   { email = e; }
};

int main() {
    // Здесь мог бы быть код для демонстрации работы всех функций и классов,
    // но по условию тебе нужен только закомментированный код.
    return 0;
}
*/
