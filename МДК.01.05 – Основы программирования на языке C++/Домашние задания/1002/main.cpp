#include <iostream>
#include <vector>
#include <string>
#include <string_view>
#include <cctype>  // isspace

// Задание 1: Количество слов в string_view
size_t countWords(std::string_view sv) {
    size_t count = 0;
    bool in_word = false;
    for (char c : sv) {
        if (!std::isspace(static_cast<unsigned char>(c))) {
            if (!in_word) {
                ++count;
                in_word = true;
            }
        } else {
            in_word = false;
        }
    }
    return count;
}

// Задание 2: Split по пробелам (vector<string>)
std::vector<std::string> split(const std::string& s) {
    std::vector<std::string> words;
    std::string word;
    for (char c : s) {
        if (std::isspace(static_cast<unsigned char>(c))) {
            if (!word.empty()) {
                words.push_back(word);
                word.clear();
            }
        } else {
            word += c;
        }
    }
    if (!word.empty()) words.push_back(word);
    return words;
}

// Задание 3: Палиндром без копии (two pointers)
bool isPalindrome(std::string_view sv) {
    size_t left = 0, right = sv.size() - 1;
    while (left < right) {
        if (std::tolower(static_cast<unsigned char>(sv[left++])) != 
            std::tolower(static_cast<unsigned char>(sv[right--]))) {
            return false;
        }
    }
    return true;
}

// Задание 4: Сумма из "x=10;y=20;z=30"
int parseSum(const std::string& s) {
    int sum = 0;
    size_t pos = 0;
    while ((pos = s.find('=', pos)) != std::string::npos) {
        size_t eq_pos = pos++;
        size_t semi_pos = s.find(';', pos);
        if (semi_pos == std::string::npos) semi_pos = s.size();
        int val = std::stoi(s.substr(eq_pos + 1, semi_pos - eq_pos - 1));
        sum += val;
    }
    return sum;
}

// Задание 5: Самое длинное слово
std::string longestWord(const std::string& s) {
    std::string max_word, word;
    for (char c : s) {
        if (std::isspace(static_cast<unsigned char>(c))) {
            if (word.size() > max_word.size()) {
                max_word = word;
            }
            word.clear();
        } else {
            word += c;
        }
    }
    if (word.size() > max_word.size()) {
        max_word = word;
    }
    return max_word;
}

int main() {
    // Тесты
    std::cout << "=== Задание 1 ===\n";
    std::cout << "Слов: " << countWords("hello world test") << "\n";  // 3

    std::cout << "\n=== Задание 2 ===\n";
    auto words = split("hello world  test");
    for (const auto& w : words) std::cout << w << " ";  // hello world test
    std::cout << "\n";

    std::cout << "\n=== Задание 3 ===\n";
    std::cout << "radar палиндром: " << (isPalindrome("Radar") ? "Да" : "Нет") << "\n";  // Да

    std::cout << "\n=== Задание 4 ===\n";
    std::cout << "Сумма x=10;y=20;z=30: " << parseSum("x=10;y=20;z=30") << "\n";  // 60

    std::cout << "\n=== Задание 5 ===\n";
    std::cout << "Длинное слово: '" << longestWord("find the longest word here") << "'\n";  // longest

    return 0;
}
