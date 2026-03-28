// #include <iostream>
// #include <cstring>
//
// class String {
// private:
//     char* data;
//     size_t length;
//
// public:
//     String() : data(nullptr), length(0) {}
//
//     String(const char* str) {
//         if (str) {
//             length = strlen(str);
//             data = new char[length + 1];
//             strcpy(data, str);
//         } else {
//             data = nullptr;
//             length = 0;
//         }
//     }
//
//     String(const String& other) {
//         length = other.length;
//         if (other.data) {
//             data = new char[length + 1];
//             strcpy(data, other.data);
//         } else {
//             data = nullptr;
//         }
//     }
//
//     String& operator=(const String& other) {
//         if (this != &other) {
//             delete[] data;
//             length = other.length;
//             if (other.data) {
//                 data = new char[length + 1];
//                 strcpy(data, other.data);
//             } else {
//                 data = nullptr;
//             }
//         }
//         return *this;
//     }
//
//     ~String() {
//         delete[] data;
//     }
//
//     size_t getLength() const {
//         return length;
//     }
//
//     const char* c_str() const {
//         return data ? data : "";
//     }
// };
//
// class Buffer {
// private:
//     int* data;
//     size_t size;
//
// public:
//     Buffer() : data(nullptr), size(0) {}
//
//     Buffer(size_t s) : size(s) {
//         data = new int[size];
//         for (size_t i = 0; i < size; ++i) {
//             data[i] = 0;
//         }
//     }
//
//     Buffer(const Buffer& other) : size(other.size) {
//         data = new int[size];
//         for (size_t i = 0; i < size; ++i) {
//             data[i] = other.data[i];
//         }
//     }
//
//     Buffer& operator=(const Buffer& other) {
//         if (this != &other) {
//             delete[] data;
//             size = other.size;
//             data = new int[size];
//             for (size_t i = 0; i < size; ++i) {
//                 data[i] = other.data[i];
//             }
//         }
//         return *this;
//     }
//
//     ~Buffer() {
//         delete[] data;
//     }
//
//     void fill(int value) {
//         for (size_t i = 0; i < size; ++i) {
//             data[i] = value;
//         }
//     }
//
//     void print() const {
//         for (size_t i = 0; i < size; ++i) {
//             std::cout << data[i] << " ";
//         }
//         std::cout << std::endl;
//     }
// };
//
// int main() {
//     String s1("Hello");
//     String s2 = s1;
//     String s3;
//     s3 = s2;
//
//     std::cout << "s1: " << s1.c_str() << ", length: " << s1.getLength() << std::endl;
//     std::cout << "s2: " << s2.c_str() << ", length: " << s2.getLength() << std::endl;
//     std::cout << "s3: " << s3.c_str() << ", length: " << s3.getLength() << std::endl;
//
//     Buffer b1(5);
//     b1.fill(42);
//     std::cout << "b1: ";
//     b1.print();
//
//     Buffer b2 = b1;
//     std::cout << "b2 (после копирования b1): ";
//     b2.print();
//
//     b2.fill(100);
//     std::cout << "b2 (после изменения): ";
//     b2.print();
//
//     std::cout << "b1 (остался без изменений): ";
//     b1.print();
//
//     Buffer b3(3);
//     b3 = b1;
//     std::cout << "b3 (после присваивания b1): ";
//     b3.print();
//
//     return 0;
// }
