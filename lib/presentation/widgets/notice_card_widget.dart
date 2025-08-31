import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/notice_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/animated_container_widget.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

class NoticeCardWidget extends StatelessWidget {
  final NoticeItem noticeItem;
  final VoidCallback? onTap;

  const NoticeCardWidget({
    super.key,
    required this.noticeItem,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getCardColor(bool isRead) {
    return isRead ? Colors.grey[100]! : AppColor.primaryColor.withOpacity(0.05);
  }

  Color? _getTextColor(bool isRead) {
    return isRead ? Colors.grey[600] : AppColor.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomBlobBackground(
        blobColor: noticeItem.isRead ? Colors.grey.shade700 : AppColor.primaryColor,
        backgroundColor: _getCardColor(noticeItem.isRead),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with date and unread indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Text(
                    _formatDate(noticeItem.date),
                    style: TextStyle(
                      fontSize: Sizes.smallText(context),
                      color: _getTextColor(noticeItem.isRead),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Unread indicator
                  if (!noticeItem.isRead)
                    AnimatedCircleContainer(
                      size: Sizes.smallIcon(context),
                      color: Colors.transparent,
                      borderColor: AppColor.primaryColor,
                      borderWidth: 1,
                      animationType: ContainerAnimationType.borderPulse,
                      intensity: 0.4,
                      child: Center(
                        child: Text(
                          'New',
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontSize: Sizes.extraSmallText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                noticeItem.title,
                style: TextStyle(
                  fontSize: Sizes.normalText(context),
                  color: _getTextColor(noticeItem.isRead),
                  fontWeight: noticeItem.isRead ? FontWeight.w500 : FontWeight.bold,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            ],
          ),
        ),
      ),
    );
  }
}