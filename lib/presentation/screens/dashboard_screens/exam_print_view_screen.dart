import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExamPrintViewScreen extends StatefulWidget {
  const ExamPrintViewScreen({super.key});

  @override
  State<ExamPrintViewScreen> createState() => _ExamPrintViewScreenState();
}

class _ExamPrintViewScreenState extends State<ExamPrintViewScreen> {
  late final Map<String, dynamic> _args;
  late final String examId;
  late final String url;
  late final String title;

  late final WebViewController _controller;

  bool _pageLoading = true;
  int _loadingProgress = 0;
  bool _printing = false;

  @override
  void initState() {
    super.initState();

    _args = Get.arguments ?? {};
    examId = (_args['examId'] ?? '').toString();
    url = (_args['url'] ?? '').toString();
    title = (_args['title'] ?? 'Print View').toString();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'FlutterPrint',
        onMessageReceived: (JavaScriptMessage message) async {
          await _handleNativePrint();
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _pageLoading = true;
              _loadingProgress = 0;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (_) async {
            await _injectPageCustomization();
            if (!mounted) return;
            setState(() {
              _pageLoading = false;
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _pageLoading = false;
            });
          },
        ),
      );

    if (url.isNotEmpty) {
      _controller.loadRequest(Uri.parse(url));
    }
  }

  Future<void> _injectPageCustomization() async {
    try {
      await _controller.runJavaScript(r'''
        (function() {
          try {
            const style = document.createElement('style');
            style.innerHTML = `
              .btn,
              .btn-primary,
              .btn-light,
              .toolbar,
              .no-print {
                display: none !important;
                visibility: hidden !important;
              }
              .wrap {
                margin-top: 0 !important;
                padding-top: 0 !important;
              }
            `;
            document.head.appendChild(style);

            window.print = function() {
              FlutterPrint.postMessage('print');
            };
          } catch (e) {}
        })();
      ''');
    } catch (_) {}
  }

  Future<void> _reload() async {
    await _controller.reload();
  }

  Future<void> _handleBackPressed() async {
    if (url.isEmpty) {
      Get.back();
      return;
    }

    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
    } else {
      Get.back();
    }
  }

  Future<void> _handleNativePrint() async {
    if (_printing || url.isEmpty) return;

    setState(() {
      _printing = true;
    });

    try {
      // Fetch the HTML of the page
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final htmlContent = response.body;

        await Printing.layoutPdf(
          name: examId.isEmpty ? 'exam_answers' : 'exam_$examId',
          onLayout: (PdfPageFormat format) async {
            // Convert HTML to PDF
            final pdfBytes = await Printing.convertHtml(
              format: format,
              html: htmlContent,
            );
            return pdfBytes;
          },
        );
      } else {
        throw Exception('Failed to load printable page');
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Print failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _printing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: CommonScaffold(
        title: title.isEmpty ? 'Print View' : title,
        body: url.isEmpty
            ? const Center(
          child: Text('Invalid print url'),
        )
            : Stack(
          children: [
            Column(
              children: [
                if (_pageLoading)
                  LinearProgressIndicator(
                    value: _loadingProgress < 100
                        ? _loadingProgress / 100
                        : null,
                    minHeight: 3,
                  ),
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: _printing ? null : _handleNativePrint,
                icon: _printing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.print_rounded),
                label: Text(_printing ? 'Preparing...' : 'Print Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
