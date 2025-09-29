// invoice_webview.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoiceWebView extends StatefulWidget {
  final String url;
  final Map<String, String>? headers; // optional (e.g., auth token)

  const InvoiceWebView({
    super.key,
    required this.url,
    this.headers,
  });

  @override
  State<InvoiceWebView> createState() => _InvoiceWebViewState();
}

class _InvoiceWebViewState extends State<InvoiceWebView> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
          onWebResourceError: (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load invoice: ${err.description}')),
            );
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: widget.headers ?? const <String, String>{},
      );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_progress < 100)
            LinearProgressIndicator(value: _progress == 0 ? null : _progress / 100),
          // Give the dialog a nice, readable aspect
          SizedBox(
            width: 600,
            height: 700,
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
