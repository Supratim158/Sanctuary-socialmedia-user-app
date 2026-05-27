import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const NetworkVideoWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<NetworkVideoWidget> createState() => _NetworkVideoWidgetState();
}

class _NetworkVideoWidgetState extends State<NetworkVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isMuted = true; // Auto-play muted like Instagram
  bool _isPlaying = true;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
      _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
      _showOverlay = true;
    });

    // Hide play/pause overlay after a short delay
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  void _toggleMute() {
    if (!_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Show thumbnail as placeholder if available
          if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
            Image.network(
              widget.thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black45,
              ),
            )
          else
            Container(
              color: Colors.black45,
            ),
          const CircularProgressIndicator(
            color: Colors.purpleAccent,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // Play/Pause Overlay Indicator (Animated)
          AnimatedOpacity(
            opacity: _showOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),

          // Mute/Unmute Control
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
