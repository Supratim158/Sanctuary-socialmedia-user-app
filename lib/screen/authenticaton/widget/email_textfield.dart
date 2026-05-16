// custom_email_field.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class CustomEmailField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;

  const CustomEmailField({
    super.key,
    required this.controller,
    this.hintText = "Email or Username",
  });

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

            controller: controller,

            keyboardType: TextInputType.emailAddress,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),

            cursorColor: Colors.white,

            decoration: InputDecoration(

              hintText: hintText,

              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),

              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.white.withOpacity(0.7),
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