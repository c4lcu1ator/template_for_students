#pragma once
#include <vector>
#include <optional>
#include "Movie.h"

class MovieLibrary {
public:
    MovieLibrary();

    void addMovie(const Movie& movie);

    bool editMovie(
        int id,
        const std::string& newTitle,
        const std::string& newDirector,
        int newYear,
        Genre newGenre,
        double newRating
    );

    bool removeMovie(int id);

    std::optional<Movie> findById(int id) const;

    std::vector<Movie> filterByGenre(Genre genre) const;

    const std::vector<Movie>& getAll() const;

private:
    std::vector<Movie> movies;
    int nextId;
};
