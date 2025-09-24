// lib/presentation/screens/solve_video_screen.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/helpers/solve_video_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/fancy_card_background.dart';

import 'package:medi_exam/data/models/video_link_model.dart';
import 'package:medi_exam/data/services/video_link_service.dart';

// Alias to avoid name collisions
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yti;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:screen_protector/screen_protector.dart';

class SolveVideoScreen extends StatefulWidget {
  const SolveVideoScreen({super.key});

  @override
  State<SolveVideoScreen> createState() => _SolveVideoScreenState();
}

class _SolveVideoScreenState extends State<SolveVideoScreen> {
  final _service = VideoLinkService();
  late final Map<String, dynamic> _args;

  bool _loading = true;
  String? _error;
  VideoLinkModel? _video;
  String _videoTitle = '';

  // Play state we control (so we don't rely on YouTube UI)
  bool _isPlaying = false;

  // YouTube (Android/iOS) controller
  yti.YoutubePlayerController? _yt;

  // Windows WebView controller + ready flag for JS calls
  WebViewController? _webController;
  bool _webReady = false;

  @override
  void initState() {
    super.initState();
    _args = Get.arguments ?? const {};
    _videoTitle = (_args['videoTitle'] ?? '').toString().trim();
    _secureScreen();
    _load();
  }

  @override
  void dispose() {
    _disposePlayers();
    _unsecureScreen();
    super.dispose();
  }

  Future<void> _secureScreen() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await ScreenProtector.preventScreenshotOn();
        await ScreenProtector.protectDataLeakageOn();
      }
    } catch (_) {/* ignore */}
  }

  Future<void> _unsecureScreen() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await ScreenProtector.preventScreenshotOff();
        await ScreenProtector.protectDataLeakageOff();
      }
    } catch (_) {/* ignore */}
  }

  void _disposePlayers() {
    _yt?.close();
    _yt = null;
    _webController = null;
    _webReady = false;
  }

  Future<void> _load() async {
    final admissionId = (_args['admissionId'] ?? '').toString();
    final solveVideoId = (_args['solveVideoId'] ?? '').toString();

    if (admissionId.isEmpty || solveVideoId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Missing parameters.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _isPlaying = false;
    });

    // Use your service method name (you posted both variants; this uses fetchVideoLink)
    final resp = await _service.fetchVideoLink(admissionId, solveVideoId);
    if (!mounted) return;

    if (resp.isSuccess && resp.responseData is VideoLinkModel) {
      final model = resp.responseData as VideoLinkModel;
      if (model.hasError) {
        setState(() {
          _video = model;
          _loading = false;
          _error = model.safeError;
        });
        return;
      }
      setState(() {
        _video = model;
        _loading = false;
      });
      _setupPlayer(model);
    } else {
      setState(() {
        _loading = false;
        _error = resp.errorMessage ?? 'Failed to load video.';
      });
    }
  }

  void _setupPlayer(VideoLinkModel v) {
    _disposePlayers();

    if (v.isYouTube && v.hasLink) {
      final id = _extractYouTubeId(v.safeLink) ?? '';
      if (_isMobile) {
        // Android/iOS — use iframe player, hide controls & block interactions
        _yt = yti.YoutubePlayerController.fromVideoId(
          videoId: id,
          params: const yti.YoutubePlayerParams(
            showControls: false,         // hide YouTube UI
            showFullscreenButton: false, // hide YouTube fullscreen
            enableCaption: false,
            strictRelatedVideos: true,
            playsInline: true,
            // critical: don't let user interact with iframe directly
            pointerEvents: yti.PointerEvents.none,
            // Reduce branding (YT still shows minimal logo per policy)
          ),
          autoPlay: false,
          startSeconds: 0,
        );
      } else {
        // Windows — load our own HTML (no YT UI) and control via JS
        _webController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                // Block all navigations (no leaving/links)
                return NavigationDecision.prevent;
              },
              onPageFinished: (_) {
                _webReady = true;
              },
            ),
          )
          ..loadHtmlString(_windowsYouTubeHtml(id));
      }
      return;
    }

    // Non-YouTube providers: show generic inline page but block navigation.
    if (v.hasLink) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) => NavigationDecision.prevent,
            onPageFinished: (_) => _webReady = true,
          ),
        )
        ..loadHtmlString(_simpleInlineHtml(v.safeLink));
    }
  }

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String? _extractYouTubeId(String url) {
    try {
      final id = yti.YoutubePlayerController.convertUrlToId(url);
      if (id != null && id.isNotEmpty) return id;
    } catch (_) {}
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  // ---- Overlay controls (we call API/JS; user never taps the iframe) ----
  Future<void> _togglePlay() async {
    final v = _video;
    if (v == null) return;

    if (v.isYouTube && _isMobile && _yt != null) {
      if (_isPlaying) {
        await _yt!.pauseVideo();
      } else {
        await _yt!.playVideo();
      }
      setState(() => _isPlaying = !_isPlaying);
      return;
    }

    if (_webController != null && _webReady) {
      // Call our JS helpers in the HTML.
      if (_isPlaying) {
        await _webController!.runJavaScript('player && player.pauseVideo && player.pauseVideo();');
      } else {
        await _webController!.runJavaScript('player && player.playVideo && player.playVideo();');
      }
      setState(() => _isPlaying = !_isPlaying);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonScaffold(
      title: 'Solve Video',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _load,
            color: theme.colorScheme.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                HeaderCard(videoTitle: _videoTitle),

                const SizedBox(height: 16),

                PlayerArea(
                  loading: _loading,
                  error: _error,
                  video: _video,
                  yt: _yt,
                  webController: _webController,
                  isMobile: _isMobile,
                  isPlaying: _isPlaying,
                  onTogglePlay: _togglePlay,
                ),
              ],
            ),
          ),

          if (_loading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Center(child: LoadingWidget()),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Minimal HTML for Windows (YT API, no controls, no clicks) ----------
  String _windowsYouTubeHtml(String videoId) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    html, body { margin:0; padding:0; background:#000; }
    #container { position:relative; width:100%; height:100vh; overflow:hidden; }
    #player { width:100%; height:100%; pointer-events:none; } /* block clicks */
  </style>
</head>
<body>
  <div id="container">
    <div id="player"></div>
  </div>

  <script>
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        videoId: '$videoId',
        playerVars: {
          'autoplay': 0,
          'controls': 0,         // hide UI
          'rel': 0,
          'fs': 0,               // no fullscreen button
          'modestbranding': 1,
          'disablekb': 1,
          'iv_load_policy': 3
        },
        events: {
          'onReady': function(){ /* ready */ }
        }
      });
    }
  </script>
</body>
</html>
''';

  // Generic inline page loader (no navigation) for non-YT providers if needed.
  String _simpleInlineHtml(String url) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    html, body { margin:0; padding:0; background:#000; }
    iframe { width:100%; height:100vh; border:0; pointer-events:none; }
  </style>
</head>
<body>
  <iframe src="$url" allow="autoplay; encrypted-media"></iframe>
</body>
</html>
''';
}


