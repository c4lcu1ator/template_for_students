#include <iostream>
using namespace std;

class DynamicBuffer {
private:
    int* massiv;
    int razmer;

public:
    // Конструктор: выделяет память
    DynamicBuffer(int size) {
        razmer = size;
        massiv = new int[razmer];
    }

    // Деструктор: освобождает память
    ~DynamicBuffer() {
        delete[] massiv;
        cout << "Память освобождена" << endl;
    }

    // Метод заполнения массива
    void zapolnit(int znachenie) {
        for (int i = 0; i < razmer; ++i) {
            massiv[i] = znachenie;
        }
    }

    // Метод вывода для проверки (дополнительно)
    void vyvod() {
        for (int i = 0; i < razmer; ++i) {
            cout << massiv[i] << " ";
        }
        cout << endl;
    }
};
