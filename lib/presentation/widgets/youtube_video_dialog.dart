// lib/presentation/widgets/youtube_video_dialog.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideoDialog extends StatefulWidget {
  final String videoId;
  final String? title;
  const YouTubeVideoDialog({Key? key, required this.videoId, this.title}) : super(key: key);

  @override
  State<YouTubeVideoDialog> createState() => _YouTubeVideoDialogState();
}

class _YouTubeVideoDialogState extends State<YouTubeVideoDialog> {
  late YoutubePlayerController _yt;

  @override
  void initState() {
    super.initState();
    _yt = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
        disableDragSeek: false,
        enableCaption: false,
        forceHD: true, // request higher quality when possible
        useHybridComposition: true, // smoother on Android
      ),
    );
  }

  @override
  void dispose() {
    _yt.pause();
    _yt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260, maxWidth: 700),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black)),
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: _yt,
                    showVideoProgressIndicator: true,
                  ),
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
              if ((widget.title ?? '').trim().isNotEmpty)
                Positioned(
                  left: 12, right: 48, bottom: 8,
                  child: Text(
                    widget.title!,
                    maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
