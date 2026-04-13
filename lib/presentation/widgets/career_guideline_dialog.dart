import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/career_guidelines_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

void showCareerGuidelineLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingWidget(size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Loading guidelines...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

Future<void> showCareerGuidelineDialog({
  required BuildContext context,
  required CareerGuidelinesListModel model,
  String title = 'Post Graduation Guideline',
}) async {
  final items = model.safeCareerGuidelines;

  await showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: items.length <= 2 ? 340 : 520,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: items.isEmpty
                  ? _CareerGuidelineEmptyState(title: title)
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CareerGuidelineDialogHeader(title: title),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.25, // Tweaked to closely match Material folder icon ratio
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CareerGuidelineFolderCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).pop();
                              Get.toNamed(
                                RouteNames.careerGuidelineScreen,
                                arguments: {
                                  'folderId': item.safeId.toString(),
                                  'folderName': item.safeName,
                                  'folderColor': item.safeColor,
                                },
                                preventDuplicates: true,
                              );
                            },
                          );
                        },
                      ),
                    ),
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

class _CareerGuidelineDialogHeader extends StatelessWidget {
  final String title;

  const _CareerGuidelineDialogHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primaryColor,
                AppColor.purple,
                AppColor.indigo,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: Sizes.bodyText(context),
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          color: Colors.grey[700],
        ),
      ],
    );
  }
}

class _CareerGuidelineFolderCard extends StatelessWidget {
  final CareerGuideline item;
  final VoidCallback onTap;

  const _CareerGuidelineFolderCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final folderColor = item.parsedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.folder_rounded,
                  color: folderColor.withOpacity(0.12),
                ),
              ),
            ),
            // Adjusted padding to account for the physical bounds of the folder icon.
            // Extra top padding is added so the text avoids the "tab" of the folder.
            Padding(
              padding: const EdgeInsets.only(top: 28, left: 28, right: 28, bottom: 12),
              child: Center(
                child: Text(
                  item.safeName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Sizes.verySmallText(context),
                    fontWeight: FontWeight.w800,
                    color: folderColor,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerGuidelineEmptyState extends StatelessWidget {
  final String title;

  const _CareerGuidelineEmptyState({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CareerGuidelineDialogHeader(title: title),
          const SizedBox(height: 24),
          Icon(
            Icons.folder_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 14),
          Text(
            'No guideline folders found',
            style: TextStyle(
              fontSize: Sizes.bodyText(context),
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check again later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.smallText(context),
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}