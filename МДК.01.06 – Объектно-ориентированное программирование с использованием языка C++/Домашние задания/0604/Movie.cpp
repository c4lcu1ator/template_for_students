#include "Movie.h"

Movie::Movie()
    : id(0),
      title(""),
      director(""),
      year(0),
      genre(Genre::Unknown),
      rating(0.0)
{
}

Movie::Movie(int id,
             const std::string& title,
             const std::string& director,
             int year,
             Genre genre,
             double rating)
    : id(id),
      title(title),
      director(director),
      year(year),
      genre(genre),
      rating(rating)
{
}

int Movie::getId() const {
    return id;
}

void Movie::setId(int value) {
    id = value;
}

std::string Movie::getTitle() const {
    return title;
}

void Movie::setTitle(const std::string& value) {
    title = value;
}

std::string Movie::getDirector() const {
    return director;
}

void Movie::setDirector(const std::string& value) {
    director = value;
}

int Movie::getYear() const {
    return year;
}

void Movie::setYear(int value) {
    year = value;
}

Genre Movie::getGenre() const {
    return genre;
}

void Movie::setGenre(Genre value) {
    genre = value;
}

double Movie::getRating() const {
    return rating;
}

void Movie::setRating(double value) {
    rating = value;
}
