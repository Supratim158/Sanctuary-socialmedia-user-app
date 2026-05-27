// post_card_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanctuary/screen/home/widgets/network_video_widget.dart';

class PostCardWidget extends StatefulWidget {

  final Map<String, dynamic> postData;

  const PostCardWidget({
    super.key,
    required this.postData,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {

  late final PageController _pageController;

  int currentPage = 0;

  // Extracted from postData
  List<Map<String, dynamic>> get postMedia {
    final media = widget.postData['media'] as List<dynamic>? ?? [];
    return media
        .map((m) => m is Map<String, dynamic> ? m : <String, dynamic>{})
        .where((m) => (m['url'] ?? '').toString().isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> get taggedUsers {
    final tagged = widget.postData['taggedUsers'] as List<dynamic>? ?? [];
    return tagged
        .map((u) => u is Map<String, dynamic> ? u : <String, dynamic>{})
        .where((u) => u.isNotEmpty)
        .toList();
  }

  String get userName {
    final createdBy = widget.postData['createdBy'];
    if (createdBy is Map<String, dynamic>) {
      return createdBy['userName'] ?? 'User';
    }
    return 'User';
  }

  String get userAvatar {
    final createdBy = widget.postData['createdBy'];
    if (createdBy is Map<String, dynamic>) {
      return createdBy['profile'] ?? '';
    }
    return '';
  }

  String get caption {
    return widget.postData['caption'] ?? '';
  }

  int get likesCount {
    final likes = widget.postData['likes'] as List<dynamic>? ?? [];
    return likes.length;
  }

  String get timeAgo {
    final createdAt = widget.postData['createdAt'];
    if (createdAt == null) return '';

    try {
      final date = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showTaggedUsersSheet() {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {

        return DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (context, scrollController) {

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: Column(
                children: [

                  const SizedBox(height: 12),

                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Tagged People",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: taggedUsers.length,
                      itemBuilder: (context, index) {

                        final user = taggedUsers[index];

                        final name =
                            user['userName'] ?? 'User';

                        final avatar =
                            user['profile'] ?? '';

                        return ListTile(

                          leading: CircleAvatar(
                            radius: 24,

                            backgroundColor:
                            Colors.white.withOpacity(0.08),

                            backgroundImage: avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : null,

                            child: avatar.isEmpty
                                ? Text(
                              name
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 16,
                              ),
                            )
                                : null,
                          ),

                          title: Text(
                            name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            "@${name.toLowerCase().replaceAll(" ", "_")}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),

                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white10,
                            ),
                            child: const Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (postMedia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // USER INFO
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),

            child: Row(
              children: [

                CircleAvatar(
                  radius: 20,

                  backgroundColor:
                  Colors.white.withOpacity(0.08),

                  backgroundImage: userAvatar.isNotEmpty
                      ? NetworkImage(userAvatar)
                      : null,

                  child: userAvatar.isEmpty
                      ? Text(
                    userName
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )
                      : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        userName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),

                      if (caption.isNotEmpty)
                        Text(
                          caption.length > 30
                              ? '${caption.substring(0, 30)}...'
                              : caption,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                Icon(
                  Icons.more_horiz,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),

          // IMAGE SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),

            child: SizedBox(
              height: 350,

              child: Stack(
                children: [

                  // IMAGE/VIDEO SLIDER
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: postMedia.length,

                      onPageChanged: (value) {
                        setState(() {
                          currentPage = value;
                        });
                      },

                      itemBuilder: (context, mediaIndex) {
                        final mediaItem = postMedia[mediaIndex];
                        final url = (mediaItem['url'] ?? '').toString();
                        final type = (mediaItem['type'] ?? 'image').toString();
                        final thumbnail = mediaItem['thumbnail']?.toString();

                        if (type == 'video') {
                          return NetworkVideoWidget(
                            videoUrl: url,
                            thumbnailUrl: thumbnail,
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // MEDIA COUNT INDICATOR
                  if (postMedia.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          "${currentPage + 1}/${postMedia.length}",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // TAGGED USERS BUTTON
                  if (taggedUsers.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,

                      child: GestureDetector(
                        onTap: _showTaggedUsersSheet,

                        child: Container(
                          height: 44,
                          width: 44,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.55),

                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),

                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: Row(
              children: [

                IconButton(
                  onPressed: () {},

                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                IconButton(
                  onPressed: () {},

                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                IconButton(
                  onPressed: () {},

                  icon: const Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () {},

                  icon: const Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // LIKES & CAPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "$likesCount likes",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                if (caption.isNotEmpty) ...[

                  const SizedBox(height: 4),

                  RichText(
                    text: TextSpan(
                      children: [

                        TextSpan(
                          text: "$userName ",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),

                        TextSpan(
                          text: caption,

                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (timeAgo.isNotEmpty) ...[

                  const SizedBox(height: 6),

                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          Divider(
            color: Colors.white.withOpacity(0.08),
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}