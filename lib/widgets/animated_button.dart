// glassmorphic_button.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicButton extends StatefulWidget {

  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;
  final double width;

  const GlassmorphicButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.height = 60,
    this.width = double.infinity,
  });

  @override
  State<GlassmorphicButton> createState() =>
      _GlassmorphicButtonState();
}

class _GlassmorphicButtonState
    extends State<GlassmorphicButton> {

  bool isPressed = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });

        widget.onTap();
      },

      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 180),

        curve: Curves.easeInOut,

        transform: Matrix4.identity()
          ..scale(isPressed ? 0.96 : 1.0),

        width: widget.width,
        height: widget.height,

        child: ClipRRect(

          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(35),
          ),

          child: BackdropFilter(

            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),

            child: Container(

              decoration: BoxDecoration(

                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.05),
                  ],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(35),
                ),

                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.3,
                ),

                boxShadow: [

                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(-3, -3),
                  ),

                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(5, 8),
                  ),
                ],
              ),

              child: Center(

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    if(widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 22,
                      ),

                      const SizedBox(width: 10),
                    ],

                    Text(
                      widget.text,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}