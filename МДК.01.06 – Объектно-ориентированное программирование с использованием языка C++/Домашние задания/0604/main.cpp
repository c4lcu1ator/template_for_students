#include <iostream>
#include <limits>
#include "MovieLibrary.h"
#include "GenreUtils.h"

void printMovie(const Movie& m) {
    std::cout << "#" << m.getId() << " | "
              << m.getTitle() << " | "
              << m.getDirector() << " | "
              << m.getYear() << " | "
              << genreToString(m.getGenre()) << " | "
              << "rating=" << m.getRating()
              << '\n';
}

void printAll(const MovieLibrary& lib) {
    const auto& all = lib.getAll();
    if (all.empty()) {
        std::cout << "Библиотека пуста.\n";
        return;
    }
    for (const auto& m : all) {
        printMovie(m);
    }
}

Genre inputGenre() {
    std::cout << "Выберите жанр:\n";
    std::cout << "1 - Action\n";
    std::cout << "2 - Comedy\n";
    std::cout << "3 - Drama\n";
    std::cout << "4 - SciFi\n";
    std::cout << "5 - Horror\n";
    std::cout << "6 - Documentary\n";
    std::cout << "Ваш выбор: ";
    int g;
    std::cin >> g;
    switch (g) {
    case 1: return Genre::Action;
    case 2: return Genre::Comedy;
    case 3: return Genre::Drama;
    case 4: return Genre::SciFi;
    case 5: return Genre::Horror;
    case 6: return Genre::Documentary;
    default: return Genre::Unknown;
    }
}

void clearInput() {
    std::cin.clear();
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void addMovieMenu(MovieLibrary& lib) {
    clearInput();
    std::string title;
    std::string director;
    int year;
    double rating;

    std::cout << "Введите название: ";
    std::getline(std::cin, title);

    std::cout << "Введите режиссёра: ";
    std::getline(std::cin, director);

    std::cout << "Введите год: ";
    std::cin >> year;

    Genre genre = inputGenre();

    std::cout << "Введите рейтинг (0.0 - 10.0): ";
    std::cin >> rating;

    Movie m(0, title, director, year, genre, rating);
    lib.addMovie(m);
    std::cout << "Фильм добавлен.\n";
}

void editMovieMenu(MovieLibrary& lib) {
    std::cout << "Введите id фильма для редактирования: ";
    int id;
    std::cin >> id;

    auto existing = lib.findById(id);
    if (!existing.has_value()) {
        std::cout << "Фильм с таким id не найден.\n";
        return;
    }

    const Movie& old = existing.value();
    clearInput();

    std::string title;
    std::string director;
    int year;
    double rating;

    std::cout << "Старое название: " << old.getTitle() << "\nНовое (пусто = оставить): ";
    std::getline(std::cin, title);
    if (title.empty()) {
        title = old.getTitle();
    }

    std::cout << "Старый режиссёр: " << old.getDirector() << "\nНовый (пусто = оставить): ";
    std::string dirInput;
    std::getline(std::cin, dirInput);
    if (dirInput.empty()) {
        director = old.getDirector();
    } else {
        director = dirInput;
    }

    std::cout << "Старый год: " << old.getYear() << "\nНовый (0 = оставить): ";
    std::cin >> year;
    if (year == 0) {
        year = old.getYear();
    }

    std::cout << "Старый рейтинг: " << old.getRating() << "\nНовый (-1 = оставить): ";
    std::cin >> rating;
    if (rating < 0.0) {
        rating = old.getRating();
    }

    std::cout << "Текущий жанр: " << genreToString(old.getGenre()) << "\n";
    std::cout << "Изменить жанр? (1 - да, 0 - нет): ";
    int changeGenre;
    std::cin >> changeGenre;
    Genre genre = old.getGenre();
    if (changeGenre == 1) {
        genre = inputGenre();
    }

    bool ok = lib.editMovie(id, title, director, year, genre, rating);
    if (ok) {
        std::cout << "Фильм обновлён.\n";
    } else {
        std::cout << "Ошибка при обновлении.\n";
    }
}

void filterMenu(const MovieLibrary& lib) {
    Genre genre = inputGenre();
    auto list = lib.filterByGenre(genre);
    if (list.empty()) {
        std::cout << "Фильмы выбранного жанра не найдены.\n";
        return;
    }
    std::cout << "Фильмы жанра " << genreToString(genre) << ":\n";
    for (const auto& m : list) {
        printMovie(m);
    }
}

void removeMovieMenu(MovieLibrary& lib) {
    std::cout << "Введите id фильма для удаления: ";
    int id;
    std::cin >> id;
    bool ok = lib.removeMovie(id);
    if (ok) {
        std::cout << "Фильм удалён.\n";
    } else {
        std::cout << "Фильм с таким id не найден.\n";
    }
}

int main() {
    MovieLibrary lib;

    lib.addMovie(Movie(0, "Inception", "Christopher Nolan", 2010, Genre::SciFi, 8.8));
    lib.addMovie(Movie(0, "The Dark Knight", "Christopher Nolan", 2008, Genre::Action, 9.0));
    lib.addMovie(Movie(0, "The Hangover", "Todd Phillips", 2009, Genre::Comedy, 7.7));

    while (true) {
        std::cout << "\n=== Библиотека фильмов ===\n";
        std::cout << "1. Показать все фильмы\n";
        std::cout << "2. Добавить фильм\n";
        std::cout << "3. Редактировать фильм\n";
        std::cout << "4. Удалить фильм\n";
        std::cout << "5. Фильтр по жанру\n";
        std::cout << "0. Выход\n";
        std::cout << "Ваш выбор: ";

        int choice;
        std::cin >> choice;

        if (!std::cin) {
            clearInput();
            continue;
        }

        switch (choice) {
        case 1:
            printAll(lib);
            break;
        case 2:
            addMovieMenu(lib);
            break;
        case 3:
            editMovieMenu(lib);
            break;
        case 4:
            removeMovieMenu(lib);
            break;
        case 5:
            filterMenu(lib);
            break;
        case 0:
            std::cout << "До свидания!\n";
            return 0;
        default:
            std::cout << "Неизвестная команда.\n";
            break;
        }
    }
}
