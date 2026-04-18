#pragma once
#include <stdexcept>
#include <iostream>

class Array
{
private:
    static const int SIZE = 5;
    int data[SIZE];

public:
    Array()
    {
        for (int i = 0; i < SIZE; ++i)
            data[i] = 0;
    }

    int& operator[](int index)
    {
        if (index < 0 || index >= SIZE)
            throw std::out_of_range("Array index out of range");
        return data[index];
    }

    const int& operator[](int index) const
    {
        if (index < 0 || index >= SIZE)
            throw std::out_of_range("Array index out of range");
        return data[index];
    }

    int size() const { return SIZE; }

    void print() const
    {
        for (int i = 0; i < SIZE; ++i)
            std::cout << data[i] << ' ';
        std::cout << '\n';
    }
};
