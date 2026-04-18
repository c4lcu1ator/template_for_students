#pragma once
#include <string>

enum class Genre {
    Action,
    Comedy,
    Drama,
    SciFi,
    Horror,
    Documentary,
    Unknown
};

class Movie {
private:
    int         id;
    std::string title;
    std::string director;
    int         year;
    Genre       genre;
    double      rating;

public:
    Movie();
    Movie(int id,
          const std::string& title,
          const std::string& director,
          int year,
          Genre genre,
          double rating);

    int  getId() const;
    void setId(int value);

    std::string getTitle() const;
    void        setTitle(const std::string& value);

    std::string getDirector() const;
    void        setDirector(const std::string& value);

    int  getYear() const;
    void setYear(int value);

    Genre getGenre() const;
    void  setGenre(Genre value);

    double getRating() const;
    void   setRating(double value);
};
