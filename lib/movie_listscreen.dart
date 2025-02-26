import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'movie.dart';
import 'addmovie.dart';
import 'login.dart';
import 'api.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Movie>> _movies;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    setState(() {
      _movies = _apiService.fetchMovies();
    });
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Movie movie) {
    TextEditingController titleController = TextEditingController(text: movie.title);
    TextEditingController genreController = TextEditingController(text: movie.genre);
    TextEditingController releaseDateController = TextEditingController(text: movie.releaseDate);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Movie"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: genreController, decoration: const InputDecoration(labelText: "Genre")),
              TextField(
                controller: releaseDateController,
                decoration: const InputDecoration(
                  labelText: "Release Date (YYYY-MM-DD)",
                  suffixIcon: Icon(Icons.calendar_today), // Calendar icon added
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(movie.releaseDate) ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    releaseDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
             
             onPressed: () async {
  Movie updatedMovie = Movie(
    id: movie.id,
    title: titleController.text,
    genre: genreController.text,
    releaseDate: releaseDateController.text,
  );
  
  try {
    await _apiService.updateMovie(updatedMovie);
    Navigator.pop(context);
    _loadMovies();  // Refresh the movie list
    _showSuccessPopup("Movie updated successfully!");
  } catch (e) {
    Navigator.pop(context);
    _showSuccessPopup("Error updating movie: $e");
  }
},

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(int movieId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this movie?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiService.deleteMovie(movieId);
                  Navigator.pop(context);
                  _loadMovies();
                  _showSuccessPopup("Movie deleted successfully!");
                } catch (e) {
                  Navigator.pop(context);
                  _showSuccessPopup("Error deleting movie: $e");
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
final FlutterSecureStorage secureStorage = FlutterSecureStorage();
 Future<void> _logout() async {
  try {
    // Clear username from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear auth token from Secure Storage
    await secureStorage.delete(key: 'auth_token');

    // Navigate to login screen and remove all previous screens from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // This removes all previous routes
    );
  } catch (e) {
    print("Error during logout: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChillFlex', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 202, 24, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load movies: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No movies available.'));
          }

          List<Movie> movies = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              Movie movie = movies[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    movie.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Genre: ${movie.genre}", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      const SizedBox(height: 5),
                      Text("Release Date: ${formatDate(movie.releaseDate)}",
                          style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(movie)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteDialog(movie.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddMovieScreen())).then((_) {
            _loadMovies();
          });
        },
        backgroundColor: const Color.fromARGB(255, 202, 24, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
