import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'movie.dart';

class ApiService {
  final String baseUrl = "https://192.168.1.10:7173/api";
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get the stored auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Register User
  Future<String> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        return "Registration successful!";
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['message'] ?? "Username already exists";
      } else if (response.statusCode == 500) {
        return "Internal server error. Please try again later.";
      } else {
        return "Technical problem, try again later.";
      }
    } catch (e) {
      return "Technical problem, try again later.";
    }
  }

  // Login and store token
  Future<bool> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('token')) {
          await _secureStorage.write(key: 'auth_token', value: responseData['token']);
          return true;
        }
        throw Exception("Login failed: No token received.");
      } else if (response.statusCode == 401) {
        throw Exception("Invalid credentials. Please try again.");
      } else {
        throw Exception("Login failed: Server responded with ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error logging in: $e");
    }
  }

  // Fetch Movies (GET)
  Future<List<Movie>> fetchMovies() async {
    try {
      String? token = await getToken();
      if (token == null) throw Exception("No Auth Token Found! Please login again.");

      final response = await http.get(
        Uri.parse("$baseUrl/Movies"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load movies: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching movies: $e");
    }
  }

  // Add a New Movie (POST)
  Future<bool> addMovie(String title, String genre, String releaseDate) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Unauthorized: Please login again.");

      final response = await http.post(
        Uri.parse("$baseUrl/Movies"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": title,
          "genre": genre,
          "releaseDate": releaseDate,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to add movie: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding movie: $e");
    }
  }

  // Update Movie (PUT)
  Future<void> updateMovie(Movie movie) async {
    try {
      String? token = await getToken();
      if (token == null) throw Exception("Unauthorized: Please login again.");
      if (movie.id == null || movie.id == 0) throw Exception("Invalid movie ID: ${movie.id}");

      final Uri url = Uri.parse("$baseUrl/Movies/${movie.id}");

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "id": movie.id,
          "title": movie.title,
          "genre": movie.genre,
          "releaseDate": movie.releaseDate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Movie updated successfully!");
      } else if (response.statusCode == 404) {
        throw Exception("Failed to update movie: Movie not found (404). Check if ID ${movie.id} exists.");
      } else {
        throw Exception("Failed to update movie. Server responded with ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating movie: $e");
    }
  }

  // Delete a Movie (DELETE)
  Future<bool> deleteMovie(int id) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Unauthorized: Please login again.");

      final response = await http.delete(
        Uri.parse("$baseUrl/Movies/$id"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Failed to delete movie: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting movie: $e");
    }
  }
}
