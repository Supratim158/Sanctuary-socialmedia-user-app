import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareButtonWidget extends StatelessWidget {

  final VoidCallback onTap;

  const ShareButtonWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(
        width: double.infinity,
        height: 54,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent.shade200,
              Colors.blueAccent.shade200,
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent
                  .withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,

            child: Center(
              child: Text(
                "Share Post",

                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
