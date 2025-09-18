import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Dialog that shows a YouTube player (max height 250, not full screen)
class YouTubeVideoDialog extends StatefulWidget {
  final String videoId;
  final String? title;

  const YouTubeVideoDialog({
    Key? key,
    required this.videoId,
    this.title,
  }) : super(key: key);

  @override
  State<YouTubeVideoDialog> createState() => _YouTubeVideoDialogState();
}

class _YouTubeVideoDialogState extends State<YouTubeVideoDialog> {
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        enableCaption: false,
        controlsVisibleAtStart: true,
        hideControls: false,
        hideThumbnail: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.pause();
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cap dialog height to 250; width adapts but won’t go full-screen.
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 250,
          maxWidth: 600,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Keep a 16:9 area inside the max height
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight; // <= 250
                    // Keep 16:9, but ensure we don’t exceed available width
                    final targetHeight = h;
                    final targetWidth = targetHeight * (16 / 9);
                    final width = constraints.maxWidth.clamp(0, targetWidth);
                    final height = width / (16 / 9);

                    return SizedBox(
                      width: width.toDouble(),
                      height: height.toDouble(),
                      child: YoutubePlayer(
                        controller: _ytController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: AppColor.primaryColor,
                        progressColors: ProgressBarColors(
                          playedColor: AppColor.primaryColor,
                          handleColor: AppColor.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Close button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // Optional title
              if ((widget.title ?? '').trim().isNotEmpty)
                Positioned(
                  left: 12,
                  right: 48,
                  bottom: 8,
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}