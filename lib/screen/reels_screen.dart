import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full-screen reel placeholder
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildReelItem(context, index);
            },
          ),

          // Top bar overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reels",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 26,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(BuildContext context, int index) {
    final List<Color> gradients = [
      const Color(0xFF1a1a2e),
      const Color(0xFF16213e),
      const Color(0xFF0f3460),
      const Color(0xFF1b1b2f),
      const Color(0xFF162447),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradients[index % gradients.length],
            gradients[index % gradients.length].withOpacity(0.6),
            const Color(0xFF18202D),
          ],
        ),
        image: const DecorationImage(
          image: NetworkImage(
            "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
          ),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Stack(
        children: [
          // Right side action buttons
          Positioned(
            right: 12,
            bottom: 140,
            child: Column(
              children: [
                _buildActionButton(Icons.favorite_border_rounded, "${(index + 1) * 2}K"),
                const SizedBox(height: 20),
                _buildActionButton(Icons.chat_bubble_outline_rounded, "${(index + 1) * 45}"),
                const SizedBox(height: 20),
                _buildActionButton(Icons.send_outlined, "Share"),
                const SizedBox(height: 20),
                _buildActionButton(Icons.more_vert, ""),
              ],
            ),
          ),

          // Bottom info
          Positioned(
            left: 16,
            bottom: 120,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "reel_creator_$index",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Text(
                        "Follow",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Exploring the beauty of nature 🌿 #sanctuary #explore #nature",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.white.withOpacity(0.6), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Original Audio - reel_creator_$index",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
          shadows: [Shadow(blurRadius: 8, color: Colors.black.withOpacity(0.5))],
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(blurRadius: 8, color: Colors.black.withOpacity(0.5))],
            ),
          ),
        ],
      ],
    );
  }
}
