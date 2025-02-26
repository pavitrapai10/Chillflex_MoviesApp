class Movie {
  final String title;
  final String genre;
  final String releaseDate;

  Movie({required this.title, required this.genre, required this.releaseDate});

  // Factory constructor to create a Movie from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
    );
  }
}
