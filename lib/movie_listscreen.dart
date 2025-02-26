import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'addmovie.dart';
import 'movie.dart';
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
    _movies = _apiService.fetchMovies();
    
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChillFlex', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 202, 24, 0),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      Text("Genre: ${movie.genre}",
                          style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      const SizedBox(height: 5),
                      Text("Release Date: ${formatDate(movie.releaseDate)}",
                          style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 180, 27, 0)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 202, 30, 0),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMovieScreen()),
          ).then((_) {
            setState(() {
              _movies = _apiService.fetchMovies();
            });
          });
        },
      ),
    );
  }
}
