import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text("Create Post",
                  style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _chip("Photo", Icons.photo_outlined, true),
                  const SizedBox(width: 10),
                  _chip("Video", Icons.videocam_outlined, false),
                  const SizedBox(width: 10),
                  _chip("Story", Icons.auto_stories_outlined, false),
                ]),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 260, width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                    color: Colors.white.withOpacity(0.03),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
                          child: Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.white.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 16),
                        Text("Tap to add photos or videos", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5), fontSize: 15)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white.withOpacity(0.08))),
                  child: TextField(
                    maxLines: 3,
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 15),
                    decoration: InputDecoration(hintText: "Write a caption...", hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)), border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _opt(Icons.location_on_outlined, "Add Location"),
              _opt(Icons.person_add_outlined, "Tag People"),
              _opt(Icons.music_note_outlined, "Add Music"),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [Colors.purpleAccent.shade200, Colors.blueAccent.shade200]),
                    boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () {},
                    child: Center(child: Text("Share Post", style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, bool sel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: sel ? Colors.white.withOpacity(0.12) : Colors.transparent, border: Border.all(color: Colors.white.withOpacity(sel ? 0.2 : 0.08))),
      child: Row(children: [Icon(icon, color: Colors.white.withOpacity(sel ? 0.9 : 0.4), size: 18), const SizedBox(width: 6), Text(label, style: TextStyle(color: Colors.white.withOpacity(sel ? 0.9 : 0.4), fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400))]),
    );
  }

  Widget _opt(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22), title: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)), trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 20)),
    );
  }
}
