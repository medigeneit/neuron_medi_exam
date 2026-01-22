// lib/presentation/widgets/question_explaination_button.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/question_explanation_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/question_explanation_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lazy-loads explanation for a questionId and shows a button only if available.
/// Caches results to avoid repeated calls while scrolling.
class QuestionExplainationButton extends StatefulWidget {
  final int? questionId;

  /// Optional: make it more compact where needed
  final bool compact;

  const QuestionExplainationButton({
    super.key,
    required this.questionId,
    this.compact = true,
  });

  @override
  State<QuestionExplainationButton> createState() =>
      _QuestionExplainationButtonState();
}

class _QuestionExplainationButtonState extends State<QuestionExplainationButton> {
  static final Map<String, QuestionExplanationModel?> _cache = {};
  static final Map<String, Future<QuestionExplanationModel?>> _inFlight = {};

  final _service = QuestionExplanationService();

  bool _loading = false;
  QuestionExplanationModel? _model;

  String get _key => (widget.questionId ?? '').toString();

  @override
  void initState() {
    super.initState();
    _kickoff();
  }

  @override
  void didUpdateWidget(covariant QuestionExplainationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) {
      _model = null;
      _loading = false;
      _kickoff();
    }
  }

  void _kickoff() {
    final qid = widget.questionId;
    if (qid == null || qid <= 0) return;

    // Cache hit
    if (_cache.containsKey(_key)) {
      _model = _cache[_key];
      return;
    }

    // Start fetch once
    _fetchOnce(qid);
  }

  Future<void> _fetchOnce(int questionId) async {
    setState(() => _loading = true);

    Future<QuestionExplanationModel?> future;
    if (_inFlight.containsKey(_key)) {
      future = _inFlight[_key]!;
    } else {
      future = _doFetch(questionId);
      _inFlight[_key] = future;
    }

    final result = await future;
    if (!mounted) return;

    _cache[_key] = result;
    _inFlight.remove(_key);

    setState(() {
      _model = result;
      _loading = false;
    });
  }

  Future<QuestionExplanationModel?> _doFetch(int questionId) async {
    try {
      final NetworkResponse resp =
      await _service.fetchQuestionExplanation(questionId.toString());

      if (!resp.isSuccess || resp.responseData == null) {
        // cache negative too (null model) so we don't spam server
        return null;
      }

      final data = resp.responseData;

      if (data is QuestionExplanationModel) return data;

      if (data is Map<String, dynamic>) {
        return QuestionExplanationModel.fromAny(data);
      }

      if (data is String) {
        final decoded = jsonDecode(data);
        return QuestionExplanationModel.fromAny(decoded);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  bool get _hasExplanation {
    final m = _model;
    if (m == null) return false;
    final has = (m.hasExplanation ?? false);
    final body = m.explanation?.bodyHtml;
    return has && body != null && body.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Keep UI compact:
    // - While loading, show nothing OR tiny spinner (optional).
    if (_loading && widget.compact) {
      return const SizedBox.shrink();
    }

    if (!_hasExplanation) {
      return const SizedBox.shrink();
    }

    final btnStyle = widget.compact
        ? OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: const Size(0, 34),
      side: BorderSide(color: AppColor.indigo.withOpacity(0.35)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    )
        : null;

    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        style: btnStyle,
        onPressed: _openDialog,
        icon: Icon(
          Icons.lightbulb_outline_rounded,
          size: widget.compact ? 18 : 20,
          color: AppColor.indigo,
        ),
        label: Text(
          'Explanation',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: Sizes.verySmallText(context),
            color: AppColor.primaryTextColor,
          ),
        ),
      ),
    );
  }

  void _openDialog() {
    final html = _model?.explanation?.bodyHtml ?? '';
    if (html.trim().isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row: title + close
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          size: 20, color: AppColor.indigo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Explanation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),

                  const SizedBox(height: 10),

                  // Body (scrollable)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      // keep dialog compact but usable
                      maxHeight: MediaQuery.of(context).size.height * 0.70,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Html(
                        data: html,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            lineHeight: const LineHeight(1.35),
                            color: AppColor.primaryTextColor,
                          ),
                          "img": Style(
                            width: Width(100, Unit.percent),
                          ),
                          "table": Style(
                            width: Width(100, Unit.percent),
                          ),
                        },
                        onLinkTap: (url, attrs, element) async {
                          if (url == null) return;
                          final uri = Uri.tryParse(url);
                          if (uri == null) return;
                          // best effort: open links safely
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                       /* onImageTap: (url, attrs, element) {
                          if (url == null) return;
                          _openImagePreview(url);
                        },*/
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openImagePreview(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: CustomBlobBackground(
          backgroundColor: Colors.white,
          blobColor: AppColor.indigo,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      splashRadius: 20,
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Failed to load image.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
