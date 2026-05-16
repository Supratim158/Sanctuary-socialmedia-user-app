// custom_password_field.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {

  final TextEditingController controller;
  final String hintText;

  const CustomPasswordField({
    super.key,
    required this.controller,
    this.hintText = "Password",
  });

  @override
  State<CustomPasswordField> createState() =>
      _CustomPasswordFieldState();
}

class _CustomPasswordFieldState
    extends State<CustomPasswordField> {

  bool isObsecure = true;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(

      borderRadius: BorderRadius.circular(10),

      child: BackdropFilter(

        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),

        child: Container(

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(10),

            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.05),
              ],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.2,
            ),

            boxShadow: [

              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-2, -2),
              ),

              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(4, 6),
              ),
            ],
          ),

          child: TextField(

            controller: widget.controller,

            obscureText: isObsecure,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),

            cursorColor: Colors.white,

            decoration: InputDecoration(

              hintText: widget.hintText,

              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),

              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.white.withOpacity(0.7),
              ),

              suffixIcon: IconButton(

                onPressed: () {
                  setState(() {
                    isObsecure = !isObsecure;
                  });
                },

                icon: Icon(
                  isObsecure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,

                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              border: InputBorder.none,

              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}