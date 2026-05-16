import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Profile", style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  Row(children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.add_box_outlined, color: Colors.white.withOpacity(0.7))),
                    IconButton(onPressed: () {}, icon: Icon(Icons.settings_outlined, color: Colors.white.withOpacity(0.7))),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              // Profile Picture
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.purpleAccent.shade200, Colors.blueAccent.shade200, Colors.cyanAccent])),
                child: const CircleAvatar(radius: 48, backgroundColor: Color(0xFF18202D),
                  backgroundImage: NetworkImage("https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg")),
              ),
              const SizedBox(height: 14),
              Text("Supratim", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text("@supratim_dev", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
              const SizedBox(height: 12),
              Text("Digital creator ✨ | Building Sanctuary 🏛️", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // Stats
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _stat("248", "Posts"),
                Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 30)),
                _stat("12.5K", "Followers"),
                Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 30)),
                _stat("890", "Following"),
              ]),
              const SizedBox(height: 24),
              // Edit/Share buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: Container(height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Center(child: Text("Edit Profile", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500))))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Center(child: Text("Share Profile", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500))))),
                ]),
              ),
              const SizedBox(height: 24),
              // Tab bar for grid/list/bookmarks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Icon(Icons.grid_on_rounded, color: Colors.white, size: 24),
                  Icon(Icons.video_library_outlined, color: Colors.white.withOpacity(0.35), size: 24),
                  Icon(Icons.bookmark_border_rounded, color: Colors.white.withOpacity(0.35), size: 24),
                ]),
              ),
              Divider(color: Colors.white.withOpacity(0.08), thickness: 0.5, height: 24),
              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
                      image: const DecorationImage(image: NetworkImage("https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg"), fit: BoxFit.cover)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
    ]);
  }
}
