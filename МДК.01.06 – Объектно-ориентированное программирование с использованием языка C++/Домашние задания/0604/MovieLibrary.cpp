#include "MovieLibrary.h"
#include <algorithm>

MovieLibrary::MovieLibrary()
    : nextId(1)
{
}

void MovieLibrary::addMovie(const Movie& movie) {
    Movie copy = movie;
    copy.setId(nextId++);
    movies.push_back(copy);
}

bool MovieLibrary::editMovie(
        int id,
        const std::string& newTitle,
        const std::string& newDirector,
        int newYear,
        Genre newGenre,
        double newRating
) {
    for (auto& m : movies) {
        if (m.getId() == id) {
            m.setTitle(newTitle);
            m.setDirector(newDirector);
            m.setYear(newYear);
            m.setGenre(newGenre);
            m.setRating(newRating);
            return true;
        }
    }
    return false;
}

bool MovieLibrary::removeMovie(int id) {
    auto it = std::remove_if(
        movies.begin(), movies.end(),
        [id](const Movie& m) { return m.getId() == id; }
    );
    if (it == movies.end()) {
        return false;
    }
    movies.erase(it, movies.end());
    return true;
}

std::optional<Movie> MovieLibrary::findById(int id) const {
    for (const auto& m : movies) {
        if (m.getId() == id) {
            return m;
        }
    }
    return std::nullopt;
}

std::vector<Movie> MovieLibrary::filterByGenre(Genre genre) const {
    std::vector<Movie> result;
    for (const auto& m : movies) {
        if (m.getGenre() == genre) {
            result.push_back(m);
        }
    }
    return result;
}

const std::vector<Movie>& MovieLibrary::getAll() const {
    return movies;
}
