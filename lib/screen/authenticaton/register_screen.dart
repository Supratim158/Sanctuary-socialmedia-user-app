import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sanctuary/screen/authenticaton/login_screen.dart';
import 'package:sanctuary/screen/authenticaton/widget/email_textfield.dart';
import 'package:sanctuary/screen/authenticaton/widget/password_textfield.dart';
import 'package:sanctuary/services/auth_services.dart';

import '../../widgets/animated_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    final userName = _userNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (userName.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        var isSuccess = await AuthServices.registerUser(userName, email, password);

        if (isSuccess) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please login.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(

        body: Container(

          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff0F2027),
                Color(0xff203A43),
                Color(0xff2C5364),
              ],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),

                child: BackdropFilter(

                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),

                  child: Container(

                    width: double.infinity,

                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(25),

                      color: Colors.white.withOpacity(0.08),

                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),

                              child: Image.asset(
                                "assets/images/logo.png",

                                height: 100,
                                width: 100,

                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "SANCTUARY",

                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 35),

                            CustomEmailField(
                              hintText: "User Name",
                              controller: _userNameController,
                            ),

                            const SizedBox(height: 20),

                            CustomEmailField(
                              hintText: "Email",
                              controller: _emailController,
                            ),

                            const SizedBox(height: 20),

                            CustomPasswordField(
                              controller: _passwordController,
                            ),

                            const SizedBox(height: 30),

                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : GlassmorphicButton(
                                    text: "Create",
                                    icon: Icons.arrow_forward_rounded,

                                    onTap: _register,
                                  ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                const Text(
                                  "Already have an account? ",

                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),

                                GestureDetector(

                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },

                                  child: const Text(
                                    "Login",

                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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