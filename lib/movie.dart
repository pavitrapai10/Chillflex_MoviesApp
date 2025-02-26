class Movie {
  final int id; // Add this field
  final String title;
  final String genre;
  final String releaseDate;

  Movie({required this.id, required this.title, required this.genre, required this.releaseDate});

  // Factory constructor to create a Movie from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'], // Fetch `id` from JSON
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
    );
  }

  // Convert Movie to JSON (needed for API update request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'releaseDate': releaseDate,
    };
  }
}
