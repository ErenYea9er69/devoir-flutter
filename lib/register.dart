import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'user.dart';
import 'api_config.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String get url => "$baseUrl/register";

  Future<User> register(String email, String password) async {
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return User.fromMap(
        jsonDecode(res.body),
      );
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> handleRegister() async {
    if (_formKey.currentState == null) return;

    if (_formKey.currentState!.validate()) {
      try {
        await register(_emailController.text, _passwordController.text);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
          if (!mounted) return;
          Navigator.pop(context);
          return;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not register with these credentials!',
              style: TextStyle(fontSize: 16.0),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 520.0,
                  width: 340.0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          "Register",
                          style: GoogleFonts.oswald(
                            fontWeight: FontWeight.w700,
                            fontSize: 50,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Email",
                            style: GoogleFonts.roboto(
                              fontSize: 30,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is Empty';
                            }
                            return null;
                          },
                          style: TextStyle(
                              fontSize: 20, color: Colors.blueGrey.shade700),
                          decoration: const InputDecoration(
                            errorStyle:
                                TextStyle(fontSize: 16, color: Colors.black),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 4,
                          color: const Color.fromRGBO(255, 255, 255, 0.4),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Password",
                            style: GoogleFonts.roboto(
                              fontSize: 30,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is Empty';
                            }
                            return null;
                          },
                          style: TextStyle(
                              fontSize: 20, color: Colors.blueGrey.shade700),
                          decoration: const InputDecoration(
                            errorStyle:
                                TextStyle(fontSize: 16, color: Colors.black),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor:
                                  const Color.fromRGBO(233, 65, 82, 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            onPressed: () {
                              handleRegister();
                            },
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Already have Account ?",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
