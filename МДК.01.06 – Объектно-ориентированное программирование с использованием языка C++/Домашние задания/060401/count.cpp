#pragma once
#include <iostream>

class Count
{
private:
    int value;

public:
    Count(int v = 0) : value(v) {}

    int get() const { return value; }

    Count& operator++()
    {
        ++value;
        return *this;
    }

    Count operator++(int)
    {
        Count temp(*this);
        ++value;
        return temp;
    }

    Count& operator--()
    {
        --value;
        return *this;
    }

    Count operator--(int)
    {
        Count temp(*this);
        --value;
        return temp;
    }
};

inline std::ostream& operator<<(std::ostream& os, const Count& c)
{
    os << c.get();
    return os;
}
