import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaptionInputWidget extends StatelessWidget {

  final TextEditingController controller;

  const CaptionInputWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          color: Colors.white.withOpacity(0.04),

          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),

        child: TextField(
          controller: controller,
          maxLines: 3,

          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
          ),

          decoration: InputDecoration(
            hintText: "Write a caption...",

            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
            ),

            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
