import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api.dart';

class AddMovieScreen extends StatefulWidget {
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _releaseDateController.text = formattedDate;
      });
    }
  }

  void _addMovie() async {
  if (_formKey.currentState!.validate()) {
    bool success = await _apiService.addMovie(
      _titleController.text.trim(),
      _genreController.text.trim(),
      _releaseDateController.text.trim(),
    );

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Movie added successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Close add movie screen & refresh
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to add movie."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Movie', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 194, 29, 0),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Movie Title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter movie title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.trim().isEmpty ? "Title is required" : null,
              ),
              SizedBox(height: 12),

              Text("Genre", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(
                  hintText: "Enter genre",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.trim().isEmpty ? "Genre is required" : null,
              ),
              SizedBox(height: 12),

              Text("Release Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _releaseDateController,
                decoration: InputDecoration(
                  hintText: "Select release date",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                validator: (value) => value!.trim().isEmpty ? "Release date is required" : null,
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 182, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Add Movie", style: TextStyle(fontSize: 18, color: Colors.white)),
                  onPressed: _addMovie,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
