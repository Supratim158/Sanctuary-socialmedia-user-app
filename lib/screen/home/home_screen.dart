import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanctuary/screen/home/widgets/post_card_widget.dart';
import 'package:sanctuary/services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<dynamic> _posts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final posts = await PostService.getPosts();

    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _fetchPosts,
          color: Colors.purpleAccent,
          backgroundColor: const Color(0xFF1A1A2E),
          child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: const Color(0xFF18202D),
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

            // Loading State
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent,
                  ),
                ),
              ),

            // Error State
            if (!_isLoading && _hasError)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white.withOpacity(0.3),
                        size: 48,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Couldn't load posts",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: _fetchPosts,

                        child: Text(
                          "Retry",
                          style: GoogleFonts.inter(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Empty State
            if (!_isLoading && !_hasError && _posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white.withOpacity(0.2),
                        size: 56,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "No posts yet",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Be the first to share something!",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Posts Feed
            if (!_isLoading && !_hasError && _posts.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => PostCardWidget(
                    postData: _posts[index] as Map<String, dynamic>,
                  ),
                  childCount: _posts.length,
                ),
              ),

            // Extra padding for bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
        ),
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
}
