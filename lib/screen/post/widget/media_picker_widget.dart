import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sanctuary/screen/post/widget/video_preview_widget.dart';

class MediaPickerWidget extends StatefulWidget {

  final List<XFile> selectedMedia;
  final VoidCallback onMediaChanged;

  const MediaPickerWidget({
    super.key,
    required this.selectedMedia,
    required this.onMediaChanged,
  });

  @override
  State<MediaPickerWidget> createState() =>
      _MediaPickerWidgetState();
}

class _MediaPickerWidgetState
    extends State<MediaPickerWidget> {

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {

    final List<XFile> files =
    await _picker.pickMultipleMedia();

    if (files.isNotEmpty) {

      for (var file in files) {

        // AVOID DUPLICATES
        if (!widget.selectedMedia.any(
              (e) => e.path == file.path,
        )) {
          widget.selectedMedia.add(file);
        }
      }

      widget.onMediaChanged();
    }
  }

  void _removeMedia(int index) {
    widget.selectedMedia.removeAt(index);
    widget.onMediaChanged();
  }

  bool _isVideo(String path) {

    final lower = path.toLowerCase();

    return lower.endsWith(".mp4") ||
        lower.endsWith(".mov") ||
        lower.endsWith(".avi") ||
        lower.endsWith(".mkv") ||
        lower.endsWith(".webm");
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1.5,
          ),

          color: Colors.white.withOpacity(0.03),
        ),

        child: Column(
          children: [

            // MAIN PREVIEW
            GestureDetector(
              onTap: _pickMedia,

              child: Container(
                height: 260,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: widget.selectedMedia.isEmpty

                // EMPTY STATE
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(20),

                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5,
                      sigmaY: 5,
                    ),

                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        Container(
                          padding:
                          const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: Colors.white
                                .withOpacity(0.06),
                          ),

                          child: Icon(
                            Icons
                                .add_photo_alternate_outlined,
                            size: 40,
                            color: Colors.white
                                .withOpacity(0.5),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Tap to add photos & videos",

                          style: GoogleFonts.inter(
                            color: Colors.white
                                .withOpacity(0.5),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

                // SHOW FIRST MEDIA
                    : Stack(
                  children: [

                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(20),

                      child: _isVideo(
                          widget.selectedMedia
                              .first
                              .path)

                          ? VideoPreviewWidget(
                        videoPath:
                        widget.selectedMedia
                            .first
                            .path,
                      )

                          : Image.file(
                        File(
                          widget.selectedMedia
                              .first
                              .path,
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      bottom: 14,
                      right: 14,

                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.black
                              .withOpacity(0.6),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: Text(
                          "${widget.selectedMedia.length} selected",

                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SELECTED ITEMS LIST
            if (widget.selectedMedia.isNotEmpty)
              SizedBox(
                height: 115,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.all(10),

                  itemCount:
                  widget.selectedMedia.length + 1,

                  itemBuilder: (context, index) {

                    // ADD MORE BUTTON
                    if (index ==
                        widget.selectedMedia.length) {

                      return GestureDetector(
                        onTap: _pickMedia,

                        child: Container(
                          width: 90,

                          margin:
                          const EdgeInsets.only(
                            right: 10,
                          ),

                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(16),

                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.08),
                            ),

                            color: Colors.white
                                .withOpacity(0.04),
                          ),

                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.add,
                                color: Colors.white
                                    .withOpacity(0.7),
                                size: 30,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Add",

                                style: GoogleFonts.inter(
                                  color: Colors.white
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final file =
                    widget.selectedMedia[index];

                    final bool isVideo =
                    _isVideo(file.path);

                    return Stack(
                      children: [

                        Container(
                          width: 90,

                          margin:
                          const EdgeInsets.only(
                            right: 10,
                          ),

                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(16),

                            child: isVideo

                                ? VideoPreviewWidget(
                              videoPath: file.path,
                            )

                                : Image.file(
                              File(file.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // VIDEO ICON
                        if (isVideo)
                          Positioned(
                            bottom: 8,
                            left: 8,

                            child: Container(
                              padding:
                              const EdgeInsets.all(4),

                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.55),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),

                        // REMOVE BUTTON
                        Positioned(
                          top: 6,
                          right: 16,

                          child: GestureDetector(
                            onTap: () {
                              _removeMedia(index);
                            },

                            child: Container(
                              padding:
                              const EdgeInsets.all(5),

                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.65),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
