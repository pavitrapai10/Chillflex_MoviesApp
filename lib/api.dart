import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'movie.dart';

class ApiService {
  static const String baseUrl = "https://192.168.1.95:7173/api/Movies";
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Get the stored auth token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Register User
  static Future<bool> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Registration failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error registering user: $e");
    }
  }

  // Login and store token
  static Future<bool> loginUser(String username, String password) async {
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
        } else {
          throw Exception("Login failed: No token received.");
        }
      } else {
        throw Exception("Invalid credentials. Please try again.");
      }
    } catch (e) {
      throw Exception("Error logging in: $e");
    }
  }

  // Fetch Movies
  Future<List<Movie>> fetchMovies() async {
    try {
      String? token = await getToken();
      if (token == null) throw Exception("No Auth Token Found! Please login again.");

      final response = await http.get(
        Uri.parse("$baseUrl/movies"),
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
        Uri.parse("$baseUrl/movies"),
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

  // Update a Movie (PUT)
  static Future<bool> updateMovie(int id, String title, String genre, String releaseDate) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Unauthorized: Please login again.");

      final response = await http.put(
        Uri.parse("$baseUrl/movies/$id"),
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

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to update movie: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating movie: $e");
    }
  }

  // Delete a Movie (DELETE)
  static Future<bool> deleteMovie(int id) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Unauthorized: Please login again.");

      final response = await http.delete(
        Uri.parse("$baseUrl/movies/$id"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to delete movie: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting movie: $e");
    }
  }

  // Logout Function
  static Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}
