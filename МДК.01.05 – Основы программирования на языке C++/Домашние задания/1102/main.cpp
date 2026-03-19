#include <iostream>
#include <vector>
#include <algorithm>
#include <chrono>
#include <iomanip>
#include <random>
#include <numeric>  // std::iota

void bubble_sort(std::vector<int>& arr) {
    size_t n = arr.size();
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = 0; j < n - i - 1; ++j) {
            if (arr[j] > arr[j + 1]) {
                std::swap(arr[j], arr[j + 1]);
            }
        }
    }
}

bool linear_search(const std::vector<int>& arr, int target) {
    for (int x : arr) {
        if (x == target) return true;
    }
    return false;
}

bool binary_search(const std::vector<int>& arr, int target) {
    auto low = arr.begin(), high = arr.end();
    while (low != high) {
        auto mid = low + std::distance(low, high) / 2;
        if (*mid == target) return true;
        else if (*mid < target) low = mid + 1;
        else high = mid;
    }
    return false;
}

int recursive_fib(int n) {
    if (n <= 1) return n;
    return recursive_fib(n - 1) + recursive_fib(n - 2);
}

int iterative_fib(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1;
    for (int i = 2; i <= n; ++i) {
        int next = a + b;
        a = b;
        b = next;
    }
    return b;
}

template<typename Func, typename... Args>
double measure_time(Func f, Args&&... args) {
    auto start = std::chrono::high_resolution_clock::now();
    f(std::forward<Args>(args)...);
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    return duration.count();
}

int main() {
    const size_t N = 100000;
    const int FIB_N = 30;  // rec_fib(30) разумно
    std::vector<double> times(5);

    std::vector<int> data(N);
    std::iota(data.begin(), data.end(), 0);
    std::random_shuffle(data.begin(), data.end());
    std::vector<int> sorted_data = data;
    std::sort(sorted_data.begin(), sorted_data.end());
    int target = data[N/2];

    std::cout << std::fixed << std::setprecision(2);

    // 5 замеров для каждого
    std::cout << "\n=== ЗАДАНИЕ 1-5: Замеры (мс) ===\n";
    std::cout << "std::sort\tBubble\tLinear\tBinary\tRec_Fib\tIter_Fib\n";

    for (int run = 0; run < 5; ++run) {
        // 1. std::sort
        std::vector<int> copy1 = data;
        times[0] = measure_time([](std::vector<int>& v){ std::sort(v.begin(), v.end()); }, copy1) / 1000.0;

        // 2. Bubble
        std::vector<int> copy2 = data;
        times[1] = measure_time(bubble_sort, copy2) / 1000.0;

        // 3. Linear
        times[2] = measure_time(linear_search, data, target) / 1000.0;

        // Binary
        times[3] = measure_time(binary_search, sorted_data, target) / 1000.0;

        // 4. Rec/Iter fib
        times[4] = measure_time(recursive_fib, FIB_N) / 1000.0;
        double iter_time = measure_time(iterative_fib, FIB_N) / 1000.0;

        // Вывод
        for (double t : times) std::cout << t << "\t";
        std::cout << iter_time << "\n";
    }

    // Средние
    std::cout << "\n--- СРЕДНИЕ ---\n";
    double avg[5] = {0};
    for (int i = 0; i < 5; ++i) avg[i] = std::accumulate(times.begin(), times.end(), 0.0) / 5;
    std::cout << "std::sort: " << avg[0] << "мс\n";
    std::cout << "Bubble: " << avg[1] << "мс (медленнее!)\n";
    std::cout << "Linear: " << avg[2] << "мкс\n";
    std::cout << "Binary: " << avg[3] << "мкс (быстрее)\n";
    std::cout << "Rec_Fib(30): " << avg[4] << "мс (экспонента)\n";
    std::cout << "Iter_Fib: ~0мс\n";

    return 0;
}
