import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanctuary/services/auth_services.dart';
import 'package:sanctuary/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {

  bool isLoading = true;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    fetchProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Refresh profile when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state == AppLifecycleState.resumed){
      fetchProfile();
    }

  }

  Future<void> fetchProfile() async {

    final data = await ProfileService.getProfile();

    if(data != null){

      setState(() {

        user = data;

        isLoading = false;

      });

    } else {

      debugPrint("ProfileScreen: Failed to fetch profile data");

      setState(() {

        isLoading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    if(isLoading){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),

          child: Column(
            children: [

              const SizedBox(height: 20),

              // TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    Text(
                      "Profile",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Row(
                      children: [

                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.add_box_outlined,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.settings_outlined,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PROFILE IMAGE
              Container(
                padding: const EdgeInsets.all(3),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.shade200,
                      Colors.blueAccent.shade200,
                      Colors.cyanAccent,
                    ],
                  ),
                ),

                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF18202D),

                  backgroundImage: NetworkImage(
                    user?['profile'] ?? "",
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // USERNAME
              Text(
                user?['userName'] ?? "",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              // EMAIL
              Text(
                user?['email'] ?? "",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              // BIO
              Text(
                user?['bio'] ?? "",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // STATS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  _stat("0", "Posts"),

                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                  ),

                  _stat(
                    "${user?['followers']?.length ?? 0}",
                    "Followers",
                  ),

                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                  ),

                  _stat(
                    "${user?['following']?.length ?? 0}",
                    "Following",
                  ),

                ],
              ),

              const SizedBox(height: 24),

              // BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  children: [

                    Expanded(
                      child: Container(
                        height: 42,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),

                          color: Colors.white.withOpacity(0.1),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),

                        child: Center(
                          child: Text(
                            "Edit Profile",

                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Container(
                        height: 42,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),

                          color: Colors.white.withOpacity(0.1),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),

                        child: Center(
                          child: Text(
                            "Share Profile",

                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 32),

              // LOGOUT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: GestureDetector(
                  onTap: () {

                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A2E),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        title: Text(
                          "Logout",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        content: Text(
                          "Are you sure you want to logout?",
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),

                        actions: [

                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              AuthServices.logoutUser(context);
                            },
                            child: Text(
                              "Logout",
                              style: GoogleFonts.inter(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },

                  child: Container(
                    width: double.infinity,
                    height: 46,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                      ),

                      color: Colors.redAccent.withOpacity(0.08),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent.shade100,
                          size: 20,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          "Logout",

                          style: GoogleFonts.inter(
                            color: Colors.redAccent.shade100,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {

    return Column(
      children: [

        Text(
          value,

          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
          ),
        ),

      ],
    );

  }

}