import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/models/payment_result_model.dart';
import '../../widgets/common_scaffold.dart';

class BkashWebViewPage extends StatefulWidget {
  final String initialUrl;

  /// Optional: provide a function to supply an access token if the page calls
  /// `window.flutter_inappwebview.callHandler('getAccessToken')`.
  final Future<String?> Function()? getAccessToken;

  const BkashWebViewPage({
    super.key,
    required this.initialUrl,
    this.getAccessToken,
  });

  @override
  State<BkashWebViewPage> createState() => _BkashWebViewPageState();
}

class _BkashWebViewPageState extends State<BkashWebViewPage> {
  InAppWebViewController? _controller;
  bool _loading = true;
  String? _fatalError;

  // Parse result via query params (fallback).
  PaymentResultModel? _maybeParseResultFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final qp = uri.queryParameters;
    final gateway = (qp['gateway'] ?? '').toLowerCase();
    final status = qp['status'];
    if (gateway == 'bkash' && status != null) {
      return PaymentResultModel(
        status: status,
        statusMessage: qp['statusMessage'] ?? '',
        trxID: qp['trxID'],
        gateway: 'bkash',
      );
    }
    return null;
  }

  // Handle messages from JS: window.flutter_inappwebview.callHandler('FlutterBridge', jsonString)
  void _onJsBridgeMessage(String message) {
    try {
      final decoded = json.decode(message);
      if (decoded is Map<String, dynamic>) {
        final m = PaymentResultModel.fromMap(decoded);
        if (m.gateway.toLowerCase() == 'bkash' && m.status.isNotEmpty) {
          if (!mounted) return;
          Navigator.of(context).pop<PaymentResultModel>(m);
        }
      }
    } catch (_) {
      // ignore invalid payloads
    }
  }

  Future<bool> _confirmExit() async {
    if (!mounted) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Do you want to go back and cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    ) ??
        false;
    return ok;
  }

  // Proper HTTP GET for the /update endpoint (desktop-safe).
  Future<PaymentResultModel?> _fetchBkashUpdate(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
      final req = await client.getUrl(uri);
      final res = await req.close();

      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final data = json.decode(body);
        if (data is Map<String, dynamic>) {
          final result = PaymentResultModel.fromMap(data);
          if (result.gateway.toLowerCase() == 'bkash') {
            return result;
          }
        }
      } else {
        return PaymentResultModel(
          status: 'failed',
          statusMessage: 'Payment update returned ${res.statusCode}',
          trxID: null,
          gateway: 'bkash',
        );
      }
    } catch (_) {
      return PaymentResultModel(
        status: 'failed',
        statusMessage: 'Could not parse payment result',
        trxID: null,
        gateway: 'bkash',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: CommonScaffold(
        title: "bKash Payment",
        body: _fatalError != null
            ? _ErrorView(message: _fatalError!)
            : Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                transparentBackground: false,

                /// IMPORTANT for desktop pop-ups/new windows:
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,

                /// Desktop friendliness: some payment pages expect mobile layout.
                preferredContentMode: UserPreferredContentMode.MOBILE,
                // If you still get a blocked layout, uncomment a mobile UA:
                // userAgent:
                //   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',

                // Sensible defaults:
                mediaPlaybackRequiresUserGesture: true,
                allowsInlineMediaPlayback: false,
                domStorageEnabled: true,
                databaseEnabled: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,

                // iOS/macOS niceties:
                allowsBackForwardNavigationGestures: true,
                disallowOverScroll: true,

                // Android zoom:
                builtInZoomControls: true,
                displayZoomControls: false,
              ),

              onWebViewCreated: (controller) async {
                _controller = controller;

                // Original bridge:
                _controller?.addJavaScriptHandler(
                  handlerName: 'FlutterBridge',
                  callback: (args) {
                    if (args.isNotEmpty) {
                      final message = args.first.toString();
                      _onJsBridgeMessage(message);
                    }
                    return null;
                  },
                );

                // Some bKash flows (or your page) call a host function named 'getAccessToken'.
                // We provide it here. Wire this to your backend if needed.
                _controller?.addJavaScriptHandler(
                  handlerName: 'getAccessToken',
                  callback: (args) async {
                    try {
                      if (widget.getAccessToken != null) {
                        final token = await widget.getAccessToken!.call();
                        return token ?? '';
                      }
                      // Default: return empty string so the page doesn't crash.
                      return '';
                    } catch (_) {
                      return '';
                    }
                  },
                );
              },

              onCreateWindow: (controller, createWindowRequest) async {
                // Handle window.open(...) by loading the requested URL in the SAME view.
                final targetUrl = createWindowRequest.request.url;
                if (targetUrl != null) {
                  await controller.loadUrl(urlRequest: URLRequest(url: targetUrl));
                }
                // We've handled it; do not let the platform create a separate window.
                return true;
              },

              onLoadStart: (controller, url) {
                setState(() => _loading = true);
              },

              onLoadStop: (controller, url) async {
                setState(() => _loading = false);
              },

              onProgressChanged: (controller, progress) {
                // optionally: show progress
              },

              onConsoleMessage: (controller, consoleMessage) {
                // helpful for diagnosing desktop issues
                // debugPrint('[WEBVIEW] ${consoleMessage.messageLevel.name}: ${consoleMessage.message}');
              },

              onLoadError: (controller, url, code, message) {
                setState(() {
                  _fatalError = 'Failed to load page ($code): $message';
                });
              },

              onLoadHttpError: (controller, url, statusCode, description) {
                setState(() {
                  _fatalError = 'HTTP error $statusCode: ${description ?? "Unknown error"}';
                });
              },

              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                // Keep permissive to reduce friction with sandbox hosts.
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },

              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                if (url.isEmpty) {
                  return NavigationActionPolicy.ALLOW;
                }

                // 1) Handle explicit update endpoint result
                if (url.contains('/bkash/payment/') && url.contains('/update')) {
                  final result = await _fetchBkashUpdate(url);
                  if (result != null) {
                    if (!mounted) return NavigationActionPolicy.CANCEL;
                    Navigator.of(context).pop<PaymentResultModel>(result);
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                // 2) Fallback: parse via query params
                final maybe = _maybeParseResultFromUrl(url);
                if (maybe != null) {
                  if (!mounted) return NavigationActionPolicy.CANCEL;
                  Navigator.of(context).pop<PaymentResultModel>(maybe);
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
            ),

            if (_loading)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Unable to open payment page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
