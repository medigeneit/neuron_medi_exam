// lib/presentation/widgets/youtube_video_dialog.dart
import 'package:flutter/foundation.dart'; // kIsWeb, defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/responsive.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

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
  YoutubePlayerController? _yt;

  bool get _openExternallyOnThisPlatform =>
      !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();

    if (_openExternallyOnThisPlatform) {
      // Auto-open in external browser after first frame, then close the dialog.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final url = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } finally {
          if (mounted) Navigator.of(context).pop();
        }
      });
    } else {
      // Create the embedded player for non-desktop (e.g., mobile).
      _yt = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: false,
          playsInline: true,
          strictRelatedVideos: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Only if we created the controller (non-desktop)
    _yt?.pauseVideo();
    _yt?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showEmbedded = !_openExternallyOnThisPlatform;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: Responsive.isMobile(context) ? 240 : 340,
        ),
        child: Material(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: showEmbedded
                      ? YoutubePlayerScaffold(
                    controller: _yt!,
                    builder: (context, player) {
                      return YoutubeValueBuilder(
                        controller: _yt!,
                        builder: (context, value) {
                          if (!value.hasError) return player;
                          if (value.hasError) {
                            return _ErrorFallback(
                              videoId: widget.videoId,
                              onClose: () => Navigator.of(context).pop(),
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      );
                    },
                  )
                      : _ExternalOpenView(
                    videoId: widget.videoId,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 8,
                right: 8,
                child: _RoundIconButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExternalOpenView extends StatelessWidget {
  final String videoId;
  final VoidCallback onClose;
  const _ExternalOpenView({required this.videoId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          const Text(
            'Opening in YouTube…',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
                onClose();
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open manually'),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ErrorFallback extends StatelessWidget {
  final String videoId;
  final VoidCallback onClose;

  const _ErrorFallback({
    required this.videoId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Unable to load the video inside the app.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                  onClose();
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in YouTube'),
            ),
          ],
        ),
      ),
    );
  }
}
