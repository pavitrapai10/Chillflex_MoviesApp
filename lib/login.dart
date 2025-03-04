import 'package:api/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api.dart';
import 'movie_listscreen.dart';
import 'dart:io';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _usernameError;
  String? _passwordError;
  final _formKey = GlobalKey<FormState>();

  void _validateUsername(String value) {
    setState(() {
      _usernameError = value.isEmpty ? "Username is required" : null;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = "Password is required";
      } else if (value.length < 8) {
        _passwordError = "Minimum 8 characters required";
      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
        _passwordError = "Must contain 1 uppercase letter";
      } else if (!RegExp(r'[a-z]').hasMatch(value)) {
        _passwordError = "Must contain 1 lowercase letter";
      } else if (!RegExp(r'\d').hasMatch(value)) {
        _passwordError = "Must contain 1 digit";
      } else if (!RegExp(r'[@\\$!%*?&]').hasMatch(value)) {
        _passwordError = "Must contain 1 special character";
      } else {
        _passwordError = null;
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _login() async {
  final ApiService apiService = ApiService();
  String username = _usernameController.text.trim();
  String password = _passwordController.text;

  _validateUsername(username);
  _validatePassword(password);

  if (_usernameError != null || _passwordError != null) return;

  setState(() => _isLoading = true);

  try {
    bool success = await apiService.loginUser(username, password);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MovieListScreen()),
      );
    }
  } catch (e) {
  
  String errorMessage = e.toString().replaceAll("Exception: ", "").split(": ").last;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
  );
}


  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 2, 2),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Logo
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/logo.png"),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Login",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 20),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          errorText: _usernameError,
                        ),
                        onChanged: _validateUsername,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          errorText: _passwordError,
                        ),
                        onChanged: _validatePassword,
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 207, 207, 196),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Login", style: TextStyle(fontSize: 18)),
                        ),
                      ),

                      // Register Navigation
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: const Text("Go back to Register"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
