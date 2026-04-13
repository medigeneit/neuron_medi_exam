import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medi_exam/data/models/career_guideline_folder_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerGuidelineFileTile extends StatelessWidget {
  final CareerGuidelineFile file;

  const CareerGuidelineFileTile({
    super.key,
    required this.file,
  });

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    if (file.safeUrl.isEmpty) return;

    if (file.safeIsPdf) {
      await _openExternal(file.safeUrl);
      return;
    }

    if (file.safeIsImage) {
      await _showImageDialog(context);
      return;
    }

    await _openExternal(file.safeUrl);
  }

  Future<void> _showImageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
            maxHeight: 760,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CustomBlobBackground(
              backgroundColor: Colors.white,
              blobColor: _leadingColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            file.safeTitle.isNotEmpty
                                ? file.safeTitle
                                : 'Image Preview',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Sizes.bodyText(context),
                              fontWeight: FontWeight.w800,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Open in browser',
                          onPressed: () => _openExternal(file.safeUrl),
                          icon: const Icon(Icons.open_in_new_rounded),
                          color: AppColor.primaryColor,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Image.network(
                              file.safeUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: LoadingWidget(size: 28),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          size: 62,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            fontSize: Sizes.normalText(context),
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _openExternal(file.safeUrl),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            AppColor.primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(
                                              Icons.open_in_new_rounded),
                                          label:
                                          const Text('Open in browser'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formattedDate,
                            style: TextStyle(
                              fontSize: Sizes.smallText(context),
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openExternal(file.safeUrl),
                          icon: const Icon(Icons.open_in_browser_rounded),
                          label: const Text('Open externally'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _leadingIcon {
    if (file.safeIsPdf) return Icons.picture_as_pdf_rounded;
    if (file.safeIsImage) return Icons.image_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color get _leadingColor {
    if (file.safeIsPdf) return Colors.red;
    if (file.safeIsImage) return Colors.green;
    return AppColor.primaryColor;
  }

  String get _formattedDate {
    final raw = file.safeCreatedAt.trim();
    if (raw.isEmpty) return 'No date';

    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: CustomBlobBackground(
        backgroundColor: Colors.white,
        blobColor: _leadingColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _leadingColor.withOpacity(0.10),
                ),
                child: Icon(
                  _leadingIcon,
                  color: _leadingColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.safeTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Sizes.normalText(context),
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formattedDate,
                      style: TextStyle(
                        fontSize: Sizes.smallText(context),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }
}