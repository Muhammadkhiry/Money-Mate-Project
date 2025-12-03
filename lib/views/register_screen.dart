import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:money_mate/components/logging_button.dart';
import 'package:money_mate/components/logging_text_field.dart';
import 'package:money_mate/components/radio_list_group.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/views/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _phoneNumber = "";
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _companyTypeController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  bool _isLoading = false;
  String _userType = "customer";
  String _gender = "male";

  String? _usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return "Please enter your username";
    }
    return null;
  }

  String? _emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return "Please enter your email";
    }
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? _passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return "Please enter a password";
    }

    List<String> errors = [];

    if (password.length < 8) {
      errors.add("At least 8 characters");
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add("At least one uppercase letter (A-Z)");
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add("At least one lowercase letter (a-z)");
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add("At least one number (0-9)");
    }
    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(password)) {
      errors.add("At least one special character (! @ # ...)");
    }

    if (errors.isEmpty) {
      return null;
    }

    return "Password must contain:\n- ${errors.join("\n- ")}";
  }

  String? _confirmPasswordValidator(String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return "Please confirm your password";
    }

    if (_passwordController.text != confirm) {
      return "Passwords don't match";
    }

    return null;
  }

  String? _onConfirmChanged(String? confirm) {
    if (_passwordController.text != confirm) {
      return "Passwords don't match";
    }

    return null;
  }

  String? _phoneValidator(PhoneNumber? phone) {
    if (phone == null || phone.toString().isEmpty) {
      return "Please enter your phone number";
    }

    return null;
  }

  String? _addressValidator(String? address) {
    if (address == null || address.isEmpty) {
      return "Please enter your address";
    }

    return null;
  }

  String? _companyTypeValidator(String? type) {
    if (type == null || type.isEmpty) {
      return "Please enter your company type";
    }

    return null;
  }

  String? _companyNumberValidator(String? number) {
    if (number == null || number.isEmpty) {
      return "Please enter your company number";
    }

    return null;
  }

  String? _salaryValidator(String? salary) {
    if (salary == null || salary.isEmpty) {
      return "Please enter your salary";
    }

    if (int.tryParse(salary) == null && int.tryParse(salary)! <= 0) {
      return "Please enter a valid salary";
    }

    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // تحويل الـ gender لـ حرف واحد لو userType هو customer
    String genderValue = "";
    if (_userType == "customer") {
      genderValue = _gender == "male" ? "M" : "F";
    }

    final body = {
      "username": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "phone": _phoneNumber,
      "user_address": _addressController.text,
      "user_type": _userType,
      "gender": genderValue,
      "com_type": _userType == "company" ? _companyTypeController.text : "",
      "registration_number": _userType == "company"
          ? _registrationNumberController.text
          : "",
    };

    debugPrint("Register body: ${jsonEncode(body)}"); // للتأكد قبل الإرسال

    final url = Uri.parse("http://10.0.2.2:3000/api/${EndPoint.register}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json["error"] ?? "Registration Failed")),
        );
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Network Error")));
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
              height: 200,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Icon(Icons.wallet, size: 100, color: Colors.white),
                  Text(
                    "Register",
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
              padding: const EdgeInsets.only(top: 20, right: 40, left: 40),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        LoggingTextField(
                          hint: "Username",
                          controller: _usernameController,
                          isSecured: false,
                          validator: _usernameValidator,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 20),
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
                          controller: _emailController,
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
                          controller: _passwordController,
                          isSecured: true,
                          validator: _passwordValidator,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Confirm Password",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        LoggingTextField(
                          hint: "Confirm Password",
                          controller: _confirmPasswordController,
                          isSecured: true,
                          validator: _confirmPasswordValidator,
                          onChanged: _onConfirmChanged,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Phone",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        IntlPhoneField(
                          validator: _phoneValidator,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xff4CAF50)),
                            ),
                          ),
                          initialCountryCode: 'EG',
                          onChanged: (phone) =>
                              _phoneNumber = phone.completeNumber,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Address",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        LoggingTextField(
                          hint: "Address",
                          controller: _addressController,
                          isSecured: false,
                          validator: _addressValidator,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Account Type",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  RadioListGroup(
                    titles: ["Customer", "Company"],
                    values: ["customer", "company"],
                    selected: _userType,
                    onChanged: (value) =>
                        setState(() => _userType = value.toString()),
                  ),

                  if (_userType == "customer") ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RadioListGroup(
                      titles: ["Male", "Female"],
                      values: ["male", "female"],
                      selected: _gender,
                      onChanged: (value) =>
                          setState(() => _gender = value.toString()),
                    ),
                    SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Salary",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    LoggingTextField(
                      hint: "Salary",
                      controller: _salaryController,
                      isSecured: false,
                      validator: _salaryValidator,
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  if (_userType == "company") ...[
                    Text(
                      "Company Type",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    LoggingTextField(
                      hint: "Company Type",
                      controller: _companyTypeController,
                      isSecured: false,
                      validator: _companyTypeValidator,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Registration Number",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    LoggingTextField(
                      hint: "Registration Number",
                      controller: _registrationNumberController,
                      isSecured: false,
                      validator: _companyNumberValidator,
                    ),
                  ],

                  SizedBox(height: 20),
                  LoggingButton(
                    onPressed: _register,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          )
                        : Text("Register", style: TextStyle(fontSize: 30)),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign In",
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
