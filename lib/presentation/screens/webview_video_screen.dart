import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

class WebviewVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const WebviewVideoScreen({
    super.key,
    required this.videoUrl,
    this.title = 'Video',
  });

  @override
  State<WebviewVideoScreen> createState() => _WebviewVideoScreenState();
}

class _WebviewVideoScreenState extends State<WebviewVideoScreen> {
  InAppWebViewController? _webViewController;

  bool _isLoading = true;
  bool _isFullscreen = false;
  bool _isRestoring = false;

  late Uri _initialUri;
  late String _baseDomain;
  late Set<String> _allowedHosts;

  @override
  void initState() {
    super.initState();

    _initialUri = Uri.tryParse(widget.videoUrl) ?? Uri();
    _baseDomain = _extractBaseDomain(_initialUri.host);

    _allowedHosts = {
      _initialUri.host,
      if (_initialUri.host.startsWith('www.'))
        _initialUri.host.substring(4),
      if (!_initialUri.host.startsWith('www.'))
        'www.${_initialUri.host}',
      _baseDomain,
      'www.$_baseDomain',
    }..removeWhere((host) => host.trim().isEmpty);

    _allowAllOrientations();

    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(false);
    }
  }

  String _extractBaseDomain(String host) {
    final clean = host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
    final parts = clean.split('.');

    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
    }

    return clean;
  }

  bool _isSafeInternalScheme(Uri uri) {
    const safeSchemes = {
      'about',
      'blob',
      'data',
      'file',
      'javascript',
    };

    return safeSchemes.contains(uri.scheme.toLowerCase());
  }

  bool _isAllowedUrl(Uri uri) {
    final host = uri.host.toLowerCase();

    if (_isSafeInternalScheme(uri)) return true;
    if (host.isEmpty) return false;

    if (_allowedHosts.contains(host)) return true;
    if (host == _baseDomain) return true;
    if (host.endsWith('.$_baseDomain')) return true;

    return false;
  }

  void _showBlockedToast(String url) {
    // Optional.
    // Keep empty to avoid showing unnecessary messages during video redirects.
  }

  Future<void> _restoreInitialUrl(InAppWebViewController controller) async {
    if (_isRestoring) return;

    _isRestoring = true;

    try {
      await controller.stopLoading();

      if (await controller.canGoBack()) {
        await controller.goBack();
      } else {
        await controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri(widget.videoUrl),
          ),
        );
      }
    } catch (_) {
      try {
        await controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri(widget.videoUrl),
          ),
        );
      } catch (_) {}
    } finally {
      _isRestoring = false;
    }
  }

  Future<NavigationActionPolicy> _handleShouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction action,
      ) async {
    final url = action.request.url;

    if (url == null) return NavigationActionPolicy.ALLOW;

    if (action.isForMainFrame != true) {
      return NavigationActionPolicy.ALLOW;
    }

    final uri = Uri.tryParse(url.toString());

    if (uri == null) return NavigationActionPolicy.CANCEL;

    if (_isAllowedUrl(uri)) {
      return NavigationActionPolicy.ALLOW;
    }

    _showBlockedToast(uri.toString());
    await _restoreInitialUrl(controller);

    return NavigationActionPolicy.CANCEL;
  }

  void _allowAllOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _setPortraitOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _setLandscapeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _enterFullscreenUi() async {
    if (!mounted) return;

    setState(() => _isFullscreen = true);

    _setLandscapeOnly();

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  Future<void> _exitFullscreenUi() async {
    if (!mounted) return;

    setState(() => _isFullscreen = false);

    _allowAllOrientations();

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _tryExitVideoFullscreen() async {
    try {
      await _webViewController?.evaluateJavascript(
        source: """
          try {
            if (document.fullscreenElement) {
              document.exitFullscreen();
            }

            if (document.webkitFullscreenElement) {
              document.webkitExitFullscreen();
            }
          } catch(e) {}
        """,
      );
    } catch (_) {}
  }

  Future<bool> _handleBack() async {
    if (_isFullscreen) {
      await _tryExitVideoFullscreen();
      await _exitFullscreenUi();
      return false;
    }

    final canGoBack = await _webViewController?.canGoBack() ?? false;

    if (canGoBack) {
      await _webViewController?.goBack();
      return false;
    }

    _setPortraitOnly();
    return true;
  }

  @override
  void dispose() {
    _setPortraitOnly();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool effectiveFullscreen = _isFullscreen;

    final webViewWidget = Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.videoUrl),
          ),
          initialSettings: InAppWebViewSettings(
            // Important for Mali/MTK fullscreen crash:
            // false avoids one common Hybrid Composition + video surface issue.
            useHybridComposition: false,

            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            useShouldOverrideUrlLoading: true,
            javaScriptCanOpenWindowsAutomatically: false,
            supportMultipleWindows: false,
            javaScriptEnabled: true,
            supportZoom: false,
            transparentBackground: false,
            disableDefaultErrorPage: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          shouldOverrideUrlLoading: _handleShouldOverrideUrlLoading,
          onCreateWindow: (controller, action) async {
            final url = action.request.url?.toString() ?? '';

            if (url.isNotEmpty) {
              _showBlockedToast(url);
            }

            return false;
          },
          onLoadStart: (controller, url) async {
            if (mounted) {
              setState(() => _isLoading = true);
            }

            final uri = Uri.tryParse(url?.toString() ?? '');

            if (uri != null && uri.toString().isNotEmpty) {
              if (!_isAllowedUrl(uri)) {
                _showBlockedToast(uri.toString());
                await _restoreInitialUrl(controller);
              }
            }
          },
          onUpdateVisitedHistory: (controller, url, isReload) async {
            final uri = Uri.tryParse(url?.toString() ?? '');

            if (uri != null && uri.toString().isNotEmpty) {
              if (!_isAllowedUrl(uri)) {
                _showBlockedToast(uri.toString());
                await _restoreInitialUrl(controller);
              }
            }
          },
          onLoadStop: (controller, url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onLoadError: (controller, url, code, message) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onEnterFullscreen: (controller) async {
            await _enterFullscreenUi();
          },
          onExitFullscreen: (controller) async {
            await _exitFullscreenUi();
          },
        ),

        if (_isLoading)
          const Center(
            child: LoadingWidget(),
          ),
      ],
    );

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor:
        effectiveFullscreen ? Colors.black : AppColor.backgroundColor,
        appBar: effectiveFullscreen
            ? null
            : AppBar(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              final shouldPop = await _handleBack();

              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          top: !effectiveFullscreen,
          bottom: !effectiveFullscreen,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: effectiveFullscreen ? double.infinity : 1200,
              ),
              child: Column(
                children: [
                  // Very important:
                  // Keep WebView always here. Do not move it between Scaffold trees.
                  Expanded(
                    child: webViewWidget,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}