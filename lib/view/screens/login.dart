import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zee/view/screens/home.dart'; // Import for shared preferences

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double height;
  late double width;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = true; // For the loading state when checking auto-login

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if the user is already logged in
  }

  // Check if user is already logged in by checking shared preferences
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    final storedPassword = prefs.getString('password');

    if (storedUsername != null && storedPassword != null) {
      // Attempt auto-login using stored credentials
      await _login(storedUsername, storedPassword, autoLogin: true);
    } else {
      setState(() {
        _isLoading = false; // If no stored credentials, show the login page
      });
    }
  }

  /// API method for login
  Future<void> _login(
    String? username,
    String? password, {
    bool autoLogin = false,
  }) async {
    // Use passed username/password for auto-login, or from the text controllers otherwise
    final loginUsername =
        autoLogin ? username : _usernameController.text.trim();
    final loginPassword =
        autoLogin ? password : _passwordController.text.trim();

    if (loginUsername == null ||
        loginPassword == null ||
        loginUsername.isEmpty ||
        loginPassword.isEmpty) {
      _showSnackbar('Login failed: Missing credentials');
      setState(() {
        _isLoading = false; // Stop loading if auto-login fails
      });
      return;
    }

    final url = Uri.parse(
      'https://zeemax.regenterp.com/api/resource/User%20Creation?fields=[%22name%22,%22password%22]',
    );

    final headers = {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('ed4bbea42d574b6:11d2aaabc1967e0'))}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          print("Login data: $data");
        }

        if (data is Map &&
            data.containsKey('data') &&
            data['data'].isNotEmpty) {
          bool isAuthenticated = false;

          for (var userData in data['data']) {
            final apiUsername = (userData['name'] as String).trim();
            final apiPassword = (userData['password'] as String).trim();

            if (apiUsername.toLowerCase() == loginUsername.toLowerCase() &&
                apiPassword == loginPassword) {
              // If it's not an auto login, store the credentials
              if (!autoLogin) {
                await _storeCredentials(
                  loginUsername,
                  loginPassword,
                ); // Store the credentials
              }

              Get.offAll(const Home());
              isAuthenticated = true;
              break;
            }
          }

          if (!isAuthenticated) {
            _showSnackbar('Login failed: Incorrect username or password');
            setState(() {
              _isLoading = false; // Stop loading
            });
          }
        } else {
          _showSnackbar('Login failed: User not found');
          setState(() {
            _isLoading = false; // Stop loading
          });
        }
      } else {
        _showSnackbar(
          'Login failed: Server error (Status code: ${response.statusCode})',
        );
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      print('Error: $e'); // Log the error for debugging
      _showSnackbar('Login failed: Network error');
      setState(() {
        _isLoading = false; // Stop loading in case of error
      });
    }
  }

  // Store login credentials in shared preferences
  Future<void> _storeCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  // Show Snackbar for error or success messages
  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    // Show a loading indicator while checking login status
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: Center(
          child: Text(
            "Login Page",
            style: GoogleFonts.outfit(
              textStyle: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.h),
              Image.asset("assets/log.png"),
              SizedBox(height: 10.h),
              SizedBox(
                height: 60.h,
                width: 400.w,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "   Username",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 60.h,
                width: 400.w,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "   Password",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.black,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap:
                    () => _login(
                      null,
                      null,
                    ), // Login using the entered credentials
                child: Container(
                  height: 45.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
