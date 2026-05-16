import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            title: Text(
              "Sanctuary",
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),

          // Stories Section
          SliverToBoxAdapter(
            child: Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddStory();
                  }
                  return _buildStoryAvatar("User $index");
                },
              ),
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Divider(color: Colors.white.withOpacity(0.08), thickness: 0.5),
          ),

          // Posts Feed
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPostCard(context, index),
              childCount: 5,
            ),
          ),

          // Extra padding for bottom nav
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: Icon(Icons.add, color: Colors.white.withOpacity(0.7), size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            "Your Story",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent.shade200,
                  Colors.blueAccent.shade200,
                  Colors.cyanAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF18202D),
              backgroundImage: const NetworkImage(
                "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: const NetworkImage(
                    "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "sanctuary_user",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Golden Hour ✨",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),

          // Post Image
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 26),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined, color: Colors.white, size: 24),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 26),
                ),
              ],
            ),
          ),

          // Likes and caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${(index + 1) * 128} likes",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "sanctuary_user ",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: "Living in the moment 🌅 #sanctuary #peaceful",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "2 hours ago",
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
