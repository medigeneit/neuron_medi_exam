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

class _QuestionExplainationButtonState
    extends State<QuestionExplainationButton> {
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

    if (_cache.containsKey(_key)) {
      _model = _cache[_key];
      return;
    }

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

  bool _htmlHasImage(String html) {
    final lower = html.toLowerCase();
    return lower.contains('<img');
  }

  @override
  Widget build(BuildContext context) {
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
      side: BorderSide(color: AppColor.blue.withOpacity(0.35)),
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
          size: widget.compact ? 14 : 18,
          color: AppColor.blue,
        ),
        label: Text(
          'Exp',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: Sizes.extraSmallText(context),
            color: AppColor.primaryTextColor,
          ),
        ),
      ),
    );
  }

  void _openDialog() {
    final html = _model?.explanation?.bodyHtml ?? '';
    final reference = _model?.reference?.trim() ?? '';

    if (html.trim().isEmpty) return;

    final hasImage = _htmlHasImage(html);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.blue,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: AppColor.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Explanation',
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
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

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.70,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Html(
                            data: html,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                lineHeight: const LineHeight(1.35),
                                color: AppColor.primaryTextColor,
                              ),
                              "table": Style(
                                width: Width(100, Unit.percent),
                              ),
                              "img": Style(
                                display: Display.block,
                                width: Width(100, Unit.percent),
                                margin: Margins.symmetric(vertical: 12),
                              ),
                              "p": Style(
                                margin: Margins.only(bottom: 10),
                              ),
                            },
                            extensions: [
                              TagExtension(
                                tagsToExtend: {"img"},
                                builder: (extensionContext) {
                                  final src =
                                  extensionContext.attributes['src']?.trim();

                                  if (src == null || src.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _openImagePreview(src),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minHeight: 160,
                                                maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.42,
                                                minWidth: double.infinity,
                                              ),
                                              child: Image.network(
                                                src,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                loadingBuilder: (context, child,
                                                    progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    alignment: Alignment.center,
                                                    height: 180,
                                                    child:
                                                    const CircularProgressIndicator(),
                                                  );
                                                },
                                                errorBuilder: (_, __, ___) {
                                                  return Container(
                                                    width: double.infinity,
                                                    padding:
                                                    const EdgeInsets.all(16),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'Failed to load image',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.touch_app_rounded,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Tap to view full screen',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                            onLinkTap: (url, attrs, element) async {
                              if (url == null) return;
                              final uri = Uri.tryParse(url);
                              if (uri == null) return;

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),

                          if (reference.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.blue.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColor.blue.withOpacity(0.18),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 18,
                                    color: AppColor.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          color: AppColor.primaryTextColor,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Reference: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(text: reference),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (hasImage) const SizedBox(height: 4),
                        ],
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
      Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 5.0,
                  panEnabled: true,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text(
                        'Failed to load image.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}