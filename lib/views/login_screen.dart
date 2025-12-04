import 'package:flutter/material.dart';
import 'package:money_mate/components/logging_button.dart';
import 'package:money_mate/components/logging_text_field.dart';
import 'package:money_mate/controllers/controllers.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/models/user_model.dart';
import 'package:money_mate/services/api_services.dart';
import 'package:money_mate/views/com_navigation_screen.dart';
import 'package:money_mate/views/navigation_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_mate/views/register_screen.dart';

class LoginScreen extends StatefulWidget {
  static String? type, token;

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = true;
  UserModel? model;
  @override
  void initState() {
    ApiServices(api: DioConsumer()).login().then((data) {
      setState(() {
        isLoading = false;
        model = data;
      });
    });
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String? _emailValidator(String? email) {
    if (email == null || email.isEmpty) return "Please enter your email";
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegEx.hasMatch(email)) return "Please enter a valid email";
    return null;
  }

  String? _passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse("http://10.0.2.2:3000/api/${EndPoint.login}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": Controllers.emailController.text,
          "password": Controllers.passwordController.text,
        }),
      );

      final json = jsonDecode(response.body);
      LoginScreen.type = json["user"]["user_type"];
      LoginScreen.token = json["token"];

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login successful")));
        if (json["user"]["user_type"] == "customer") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NavigationScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ComNavigationScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json["message"] ?? "Login Failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network Error")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Color(0xff4CAF50),
              height: 250,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Icon(Icons.wallet, size: 100, color: Colors.white),
                  Text(
                    "Log In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 40, right: 40, left: 40),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        LoggingTextField(
                          hint: "Email",
                          controller: Controllers.emailController,
                          isSecured: false,
                          validator: _emailValidator,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        LoggingTextField(
                          hint: "Password",
                          controller: Controllers.passwordController,
                          isSecured: true,
                          validator: _passwordValidator,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xff4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  LoggingButton(
                    onPressed: _login,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          )
                        : Text("Log In", style: TextStyle(fontSize: 30)),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Color(0xff4CAF50)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
