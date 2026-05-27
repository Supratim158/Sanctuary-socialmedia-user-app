import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sanctuary/screen/post/widget/caption_input_widget.dart';
import 'package:sanctuary/screen/post/widget/media_picker_widget.dart';
import 'package:sanctuary/screen/post/widget/post_chip_widget.dart';
import 'package:sanctuary/screen/post/widget/share_button_widget.dart';
import 'package:sanctuary/screen/post/widget/tag_people_widget.dart';
import 'package:sanctuary/services/post_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  final List<XFile> selectedMedia = [];
  final List<Map<String, dynamic>> taggedUsers = [];
  final TextEditingController captionController =
  TextEditingController();

  bool _isPosting = false;

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> _sharePost() async {

    if (_isPosting) return;

    if (selectedMedia.isEmpty) {

      _showSnackBar(
        "Please select at least one photo or video.",
        isError: true,
      );

      return;
    }

    setState(() {
      _isPosting = true;
    });

    // Extract tagged user IDs
    final taggedUserIds = taggedUsers
        .map((user) =>
    (user['_id'] ?? user['userId'] ?? '')
        .toString())
        .where((id) => id.isNotEmpty)
        .toList();

    final result = await PostService.createPost(
      mediaFiles: selectedMedia,
      caption: captionController.text.trim(),
      taggedUserIds: taggedUserIds,
    );

    if (!mounted) return;

    setState(() {
      _isPosting = false;
    });

    if (result['success'] == true) {

      _showSuccessDialog();

      // Clear the form
      setState(() {
        selectedMedia.clear();
        taggedUsers.clear();
        captionController.clear();
      });

    } else {

      _showSnackBar(
        result['message'] ?? 'Failed to create post.',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        backgroundColor: isError
            ? Colors.redAccent.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {

    showDialog(
      context: context,
      barrierDismissible: true,

      builder: (context) {

        // Auto dismiss after 2 seconds
        Future.delayed(
          const Duration(seconds: 2),
              () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        );

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),

            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 20,
              ),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius:
                  BorderRadius.circular(24),

                  border: Border.all(
                    color:
                    Colors.white.withOpacity(0.12),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Container(
                      padding:
                      const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent
                                .shade200,
                            Colors.blueAccent
                                .shade200,
                          ],
                        ),
                      ),

                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Post Shared!",

                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        decoration:
                        TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Your post is now live ✨",

                      style: GoogleFonts.inter(
                        color: Colors.white
                            .withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        decoration:
                        TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // TITLE
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),

                child: Text(
                  "Create Post",

                  style:
                  GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // CHIP
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  children: [
                    PostChipWidget(
                      label: "Photo / Video",
                      icon: Icons.photo_outlined,
                      selected: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // MEDIA PICKER
              MediaPickerWidget(
                selectedMedia: selectedMedia,
                onMediaChanged: () {
                  setState(() {});
                },
              ),

              const SizedBox(height: 24),

              // CAPTION
              CaptionInputWidget(
                controller: captionController,
              ),

              const SizedBox(height: 20),

              // TAG PEOPLE
              TagPeopleWidget(
                taggedUsers: taggedUsers,
                onTagsChanged: () {
                  setState(() {});
                },
              ),

              const SizedBox(height: 28),

              // SHARE BUTTON
              _isPosting
                  ? _buildUploadingIndicator()
                  : ShareButtonWidget(
                onTap: _sharePost,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadingIndicator() {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(
        width: double.infinity,
        height: 54,

        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(16),

          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent.shade200
                  .withOpacity(0.5),
              Colors.blueAccent.shade200
                  .withOpacity(0.5),
            ],
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const SizedBox(
              width: 20,
              height: 20,

              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),

            const SizedBox(width: 14),

            Text(
              "Uploading...",

              style: GoogleFonts.inter(
                color: Colors.white
                    .withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}