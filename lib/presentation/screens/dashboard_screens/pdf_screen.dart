import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';

import 'package:medi_exam/presentation/widgets/print_button_widget.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final PdfViewerController _controller = PdfViewerController();

  late final String _url;
  late final String _title;
  late final String _fileName;

  Uint8List? _pdfBytes;
  bool _loading = true;
  bool _printing = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final args = (Get.arguments is Map)
        ? Map<String, dynamic>.from(Get.arguments)
        : <String, dynamic>{};

    _url = (args['url'] ?? '').toString().trim();
    _title = (args['title'] ?? 'Exam Materials').toString().trim();
    _fileName = (args['fileName'] ?? 'Exam-Materials').toString().trim();

    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (_url.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'PDF url not found.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _pdfBytes = null;
    });

    try {
      final uri = Uri.tryParse(_url);
      if (uri == null) throw Exception('Invalid PDF URL');

      final res = await http.get(uri);
      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bytes = res.bodyBytes;
        if (bytes.isEmpty) throw Exception('PDF is empty');

        setState(() {
          _pdfBytes = bytes;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load PDF (HTTP ${res.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _safeJobName() {
    final raw = _fileName.isNotEmpty ? _fileName : _title;
    return raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Future<void> _printPdf() async {
    if (_printing) return;

    final bytes = _pdfBytes;
    if (bytes == null) return;

    setState(() => _printing = true);
    try {
      await Printing.layoutPdf(
        name: '${_safeJobName()}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canShowPrintButton =
        !_loading && _error == null && _pdfBytes != null;

    return CommonScaffold(
      title: _title,
      floatingActionButton: canShowPrintButton
          ? PrintButton(
        onPressed: _printPdf,
        isLoading: _printing,
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _loadPdf)
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: HeaderInfoContainer(
              title: '$_title • $_fileName', // ✅ fixed string too
              icon: Icons.picture_as_pdf_outlined,
            ),
          ),

          const SizedBox(height: 8),

          // ✅ IMPORTANT: constrain height
          Expanded(
            child: SfPdfViewer.memory(
              _pdfBytes!,
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Could not open PDF',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
