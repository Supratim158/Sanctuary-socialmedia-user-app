import 'package:flutter/material.dart';

class PostChipWidget extends StatelessWidget {

  final String label;
  final IconData icon;
  final bool selected;

  const PostChipWidget({
    super.key,
    required this.label,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        color: selected
            ? Colors.white.withOpacity(0.12)
            : Colors.transparent,

        border: Border.all(
          color: Colors.white.withOpacity(
            selected ? 0.2 : 0.08,
          ),
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.white.withOpacity(
              selected ? 0.9 : 0.4,
            ),
            size: 18,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(
                selected ? 0.9 : 0.4,
              ),
              fontSize: 13,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
