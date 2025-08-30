import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/notice_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/notice_card_widget.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Column(
          children: [
            // Header with summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Updates',
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay informed with important announcements',
                        style: TextStyle(
                          fontSize: Sizes.smallText(context),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${DemoNotices.noticeList.length}',
                      style: TextStyle(
                        fontSize: Sizes.smallText(context),
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notices list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: DemoNotices.noticeList.length,
                itemBuilder: (context, index) {
                  final notice = DemoNotices.noticeList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NoticeCardWidget(
                      noticeItem: notice,
                      onTap: () {
                        // Handle notice tap - backend will mark as read
                        _showNoticeDetails(context, notice);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  void _showNoticeDetails(BuildContext context, NoticeItem notice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notice Details',
                      style: TextStyle(
                        fontSize: Sizes.titleText(context),
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${notice.date.day}/${notice.date.month}/${notice.date.year}',
                      style: TextStyle(
                        fontSize: Sizes.smallText(context),
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${notice.date.hour.toString().padLeft(2, '0')}:${notice.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: Sizes.smallText(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: notice.isRead
                        ? Colors.green.withOpacity(0.1)
                        : AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        notice.isRead
                            ? Icons.check_circle_rounded
                            : Icons.circle_rounded,
                        size: 14,
                        color: notice.isRead ? Colors.green : AppColor.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        notice.isRead ? 'Read' : 'Unread',
                        style: TextStyle(
                          fontSize: Sizes.smallText(context),
                          color: notice.isRead ? Colors.green : AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Handle any action (like share, etc.)
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Okay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}