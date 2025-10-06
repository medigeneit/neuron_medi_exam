import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/models/payment_result_model.dart';
import '../../widgets/common_scaffold.dart';

class BkashWebViewPage extends StatefulWidget {
  final String initialUrl;

  const BkashWebViewPage({
    super.key,
    required this.initialUrl,
  });

  @override
  State<BkashWebViewPage> createState() => _BkashWebViewPageState();
}

class _BkashWebViewPageState extends State<BkashWebViewPage> {
  InAppWebViewController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

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

  void _onJsBridgeMessage(String message) {
    try {
      final decoded = json.decode(message);
      if (decoded is Map<String, dynamic>) {
        final m = PaymentResultModel.fromMap(decoded);
        if (m.gateway.toLowerCase() == 'bkash' && (m.status.isNotEmpty)) {
          Navigator.of(context).pop<PaymentResultModel>(m);
        }
      }
    } catch (_) {}
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
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                transparentBackground: false,
              ),
              onWebViewCreated: (controller) async {
                _controller = controller;

                // Add JS handler for FlutterBridge.postMessage(JSON.stringify(...))
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
              },
              onLoadStart: (controller, url) {
                setState(() => _loading = true);
              },
              onLoadStop: (controller, url) async {
                setState(() => _loading = false);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                if (url.isEmpty) {
                  return NavigationActionPolicy.ALLOW;
                }

                // Handle update endpoint
                if (url.contains('/bkash/payment/') && url.contains('/update')) {
                  try {
                    final uri = Uri.parse(url);
                    final response = await NetworkAssetBundle(uri).load("");
                    final jsonStr = utf8.decode(response.buffer.asUint8List());
                    final Map<String, dynamic> data = json.decode(jsonStr);

                    final result = PaymentResultModel.fromMap(data);
                    if (result.gateway.toLowerCase() == 'bkash') {
                      Navigator.of(context).pop<PaymentResultModel>(result);
                      return NavigationActionPolicy.CANCEL;
                    }
                  } catch (e) {
                    Navigator.of(context).pop<PaymentResultModel>(
                      PaymentResultModel(
                        status: 'failed',
                        statusMessage: 'Could not parse payment result',
                        trxID: null,
                        gateway: 'bkash',
                      ),
                    );
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                // Check query params fallback
                final result = _maybeParseResultFromUrl(url);
                if (result != null) {
                  Navigator.of(context).pop<PaymentResultModel>(result);
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
