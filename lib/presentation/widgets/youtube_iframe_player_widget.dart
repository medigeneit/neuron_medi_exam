import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeIFramePlayerWidget extends StatefulWidget {
  final String? videoId;
  final String? videoUrl;

  final String origin;

  const YoutubeIFramePlayerWidget({
    super.key,
    this.videoId,
    this.videoUrl,
    this.origin = 'https://example.com',
  });

  @override
  State<YoutubeIFramePlayerWidget> createState() =>
      _YoutubeIFramePlayerWidgetState();
}

class _YoutubeIFramePlayerWidgetState extends State<YoutubeIFramePlayerWidget> {
  InAppWebViewController? _webController;

  String? _currentVideoId;
  bool _showLaunchIcon = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _currentVideoId = _resolveVideoId(widget.videoId, widget.videoUrl);
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant YoutubeIFramePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newId = _resolveVideoId(widget.videoId, widget.videoUrl);
    if (newId != null && newId != _currentVideoId) {
      _currentVideoId = newId;
      _loadVideo(newId);
    }
  }


  String? _resolveVideoId(String? videoId, String? videoUrl) {
    if (videoId != null && videoId.trim().isNotEmpty) {
      final v = videoId.trim();
      return v.length >= 11 ? v.substring(0, 11) : v;
    }
    if (videoUrl == null || videoUrl.trim().isEmpty) return null;

    final raw = videoUrl.trim();

    // Try URI parsing first (most reliable)
    try {
      final uri = Uri.parse(raw);

      // youtu.be/<id>
      if (uri.host.contains('youtu.be')) {
        final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
        if (seg.length >= 11) return seg.substring(0, 11);
      }

      // youtube.com/watch?v=<id>
      final v = uri.queryParameters['v'];
      if (v != null && v.length >= 11) return v.substring(0, 11);

      // youtube.com/shorts/<id>
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'shorts') {
        final seg = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
        if (seg.length >= 11) return seg.substring(0, 11);
      }

      // youtube.com/embed/<id>
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'embed') {
        final seg = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
        if (seg.length >= 11) return seg.substring(0, 11);
      }
    } catch (_) {
      // ignore and fall back to regex
    }

    // Regex fallback
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

    return null;
  }

  String _embedUrl(String videoId) {
    // Using youtube-nocookie tends to be more stable for embeds.
    // enablejsapi is optional here; we're primarily trying to avoid error 152.
    final origin = Uri.encodeComponent(widget.origin);

    return "https://www.youtube-nocookie.com/embed/$videoId"
        "?autoplay=1"
        "&playsinline=1"
        "&controls=1"
        "&rel=0"
        "&modestbranding=1"
        "&iv_load_policy=3"
        "&enablejsapi=1"
        "&origin=$origin";
  }

  Map<String, String> _headers() {
    // Key part: send a referer that matches your origin
    return {
      "Referer": widget.origin,
    };
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showLaunchIcon = false);
    });
  }

  void _showIconAndRestartTimer() {
    if (!mounted) return;
    if (!_showLaunchIcon) setState(() => _showLaunchIcon = true);
    _startHideTimer();
  }

  Future<void> _openInYouTube() async {
    final id = _currentVideoId;
    if (id == null) return;

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

  Future<void> _loadVideo(String videoId) async {
    if (_webController == null) return;

    await _webController!.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(_embedUrl(videoId)),
        headers: _headers(),
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = _currentVideoId;
    if (id == null) {
      return const Center(child: Text("No video available"));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showIconAndRestartTimer,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_embedUrl(id)),
                headers: _headers(),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                disableContextMenu: true,
                // Optional:
                // useHybridComposition: true,
              ),
              onWebViewCreated: (controller) {
                _webController = controller;
              },
              onLoadStop: (controller, url) {
                // Just show icon briefly when loaded
                _showIconAndRestartTimer();
              },
              onLoadError: (controller, url, code, message) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('WebView error: $code $message')),
                );
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Debug if needed:
                // debugPrint("YT console: ${consoleMessage.message}");
              },
            ),
          ),
        ],
      ),
    );
  }
}