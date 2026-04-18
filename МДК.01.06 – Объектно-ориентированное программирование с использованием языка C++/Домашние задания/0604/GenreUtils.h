#pragma once
#include <string>
#include "Movie.h"

inline std::string genreToString(Genre g) {
    switch (g) {
    case Genre::Action:      return "Action";
    case Genre::Comedy:      return "Comedy";
    case Genre::Drama:       return "Drama";
    case Genre::SciFi:       return "SciFi";
    case Genre::Horror:      return "Horror";
    case Genre::Documentary: return "Documentary";
    default:                 return "Unknown";
    }
}

inline Genre stringToGenre(const std::string& s) {
    if (s == "Action")      return Genre::Action;
    if (s == "Comedy")      return Genre::Comedy;
    if (s == "Drama")       return Genre::Drama;
    if (s == "SciFi")       return Genre::SciFi;
    if (s == "Horror")      return Genre::Horror;
    if (s == "Documentary") return Genre::Documentary;
    return Genre::Unknown;
}
