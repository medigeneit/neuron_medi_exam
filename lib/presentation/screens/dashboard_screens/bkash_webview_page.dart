// lib/presentation/screens/payment/bkash_webview_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/models/payment_result_model.dart';

class BkashWebViewPage extends StatefulWidget {
  final String initialUrl;

  /// Optionally, if your success/failure pages return results via query params,
  /// the widget will catch them automatically if `status` and `gateway=bkash`
  /// appear in the URL.
  const BkashWebViewPage({
    super.key,
    required this.initialUrl,
  });

  @override
  State<BkashWebViewPage> createState() => _BkashWebViewPageState();
}

class _BkashWebViewPageState extends State<BkashWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: _onJsBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) async {
            final url = req.url;

            // Catch only the final update endpoint
            if (url.contains('/bkash/payment/') && url.contains('/update')) {
              try {
                final uri = Uri.parse(url);
                final response = await NetworkAssetBundle(uri).load("");
                final jsonStr = utf8.decode(response.buffer.asUint8List());
                final Map<String, dynamic> data = json.decode(jsonStr);

                final result = PaymentResultModel.fromMap(data);

                if (result.gateway.toLowerCase() == 'bkash') {
                  Navigator.of(context).pop<PaymentResultModel>(result);
                  return NavigationDecision.prevent;
                }
              } catch (e) {
                // fallback if parsing fails
                Navigator.of(context).pop<PaymentResultModel>(
                  PaymentResultModel(
                    status: 'failed',
                    statusMessage: 'Could not parse payment result',
                    trxID: null,
                    gateway: 'bkash',
                  ),
                );
                return NavigationDecision.prevent;
              }
            }

            // still check query params if available
            final result = _maybeParseResultFromUrl(url);
            if (result != null) {
              Navigator.of(context).pop<PaymentResultModel>(result);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _onJsBridgeMessage(JavaScriptMessage msg) {
    // If the page posts a JSON via: FlutterBridge.postMessage(JSON.stringify({...}))
    try {
      final dynamic decoded = json.decode(msg.message);
      if (decoded is Map<String, dynamic>) {
        final m = PaymentResultModel.fromMap(decoded);
        if (m.gateway.toLowerCase() == 'bkash' && (m.status.isNotEmpty)) {
          Navigator.of(context).pop<PaymentResultModel>(m);
        }
      }
    } catch (_) {
      // ignore JSON parse errors
    }
  }

  PaymentResultModel? _maybeParseResultFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final qp = uri.queryParameters; // ?status=success&statusMessage=...&trxID=...&gateway=bkash
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

  Future<bool> _confirmExit() async {
    if (!mounted) return true;
    return await showDialog<bool>(
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: CommonScaffold(
        title: "bKash Payment",
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
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
