import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medi_exam/presentation/widgets/youtube_iframe_player_widget.dart';

class YouTubeVideoDialog extends StatefulWidget {
  /// Accepts:
  /// - raw video id
  /// - watch url
  /// - embed url
  /// - shorts url
  /// - youtu.be url
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
  String? _playableVideoUrl;
  String? _resolvedVideoId;

  @override
  void initState() {
    super.initState();

    _resolvedVideoId = _extractYouTubeId(widget.videoId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_resolvedVideoId == null || _resolvedVideoId!.isEmpty) {
        setState(() {
          _playableVideoUrl = null;
        });
        return;
      }

      // Same style as your PlaylistListScreen:
      // first clear, then mount playable video.
      setState(() => _playableVideoUrl = null);

      Future.delayed(const Duration(milliseconds: 10), () {
        if (!mounted) return;
        setState(() {
          _playableVideoUrl = widget.videoId.trim();
        });
      });
    });
  }

  String? _extractYouTubeId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final rawIdPattern = RegExp(r'^[A-Za-z0-9_-]{6,}$');
    if (rawIdPattern.hasMatch(raw) &&
        !raw.contains('http') &&
        !raw.contains('youtube') &&
        !raw.contains('youtu.be')) {
      return raw.length >= 11 ? raw.substring(0, 11) : raw;
    }

    try {
      final uri = Uri.parse(raw);

      if (uri.host.contains('youtu.be')) {
        final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
        if (seg.isNotEmpty) {
          return seg.length >= 11 ? seg.substring(0, 11) : seg;
        }
      }

      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) {
        return v.length >= 11 ? v.substring(0, 11) : v;
      }

      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'shorts') {
        final seg = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
        if (seg.isNotEmpty) {
          return seg.length >= 11 ? seg.substring(0, 11) : seg;
        }
      }

      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'embed') {
        final seg = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
        if (seg.isNotEmpty) {
          return seg.length >= 11 ? seg.substring(0, 11) : seg;
        }
      }

      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'live') {
        final seg = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
        if (seg.isNotEmpty) {
          return seg.length >= 11 ? seg.substring(0, 11) : seg;
        }
      }
    } catch (_) {}

    final shortMatch =
    RegExp(r"youtu\.be\/([_\-a-zA-Z0-9]{11})").firstMatch(raw);
    if (shortMatch != null) return shortMatch.group(1);

    final watchMatch = RegExp(r"[?&]v=([_\-a-zA-Z0-9]{11})").firstMatch(raw);
    if (watchMatch != null) return watchMatch.group(1);

    final shortsMatch =
    RegExp(r"youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11})").firstMatch(raw);
    if (shortsMatch != null) return shortsMatch.group(1);

    final embedMatch =
    RegExp(r"youtube\.com\/embed\/([_\-a-zA-Z0-9]{11})").firstMatch(raw);
    if (embedMatch != null) return embedMatch.group(1);

    final liveMatch =
    RegExp(r"youtube\.com\/live\/([_\-a-zA-Z0-9]{11})").firstMatch(raw);
    if (liveMatch != null) return liveMatch.group(1);

    return null;
  }

  Future<void> _openInYoutube() async {
    final id = _resolvedVideoId;
    if (id == null || id.isEmpty) return;

    final youtubeUrl = Uri.parse('https://www.youtube.com/watch?v=$id');
    final youtubeAppUrl = Uri.parse('youtube://watch?v=$id');

    try {
      if (await canLaunchUrl(youtubeAppUrl)) {
        await launchUrl(youtubeAppUrl);
      } else {
        await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title?.trim();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 20 : 32,
      ),
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 920,
            maxHeight: isMobile ? size.height * 0.6 : size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (title != null && title.isNotEmpty)
                            ? title
                            : 'YouTube Video',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _resolvedVideoId == null || _resolvedVideoId!.isEmpty
                      ? _ErrorFallback(
                    onOpenYoutube: _openInYoutube,
                    onClose: () => Navigator.of(context).pop(),
                    showOpenButton: false,
                  )
                      : _playableVideoUrl == null
                      ? const _LoadingView()
                      : YoutubeIFramePlayerWidget(
                    videoUrl: _playableVideoUrl!,
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Loading video...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorFallback extends StatelessWidget {
  final Future<void> Function() onOpenYoutube;
  final VoidCallback onClose;
  final bool showOpenButton;

  const _ErrorFallback({
    required this.onOpenYoutube,
    required this.onClose,
    required this.showOpenButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white70,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load this YouTube video inside the app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              if (showOpenButton)
                ElevatedButton.icon(
                  onPressed: onOpenYoutube,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in YouTube'),
                ),
              OutlinedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}