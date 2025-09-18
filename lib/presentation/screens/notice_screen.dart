import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/data/models/notice_list_model.dart';
import 'package:medi_exam/data/models/notice_details_model.dart';
import 'package:medi_exam/data/services/auth_service.dart';
import 'package:medi_exam/data/services/notice_list_service.dart';
import 'package:medi_exam/data/services/notice_details_service.dart';
import 'package:medi_exam/data/utils/notice_read_store.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/notice_card_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';


class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final NoticeListService _noticeService = NoticeListService();
  final NoticeDetailsService _noticeDetailsService = NoticeDetailsService();

  NoticeListModel? _noticeList;
  bool _isLoading = true;
  String _errorMessage = '';
  final Map<int, NoticeDetail?> _noticeDetailsCache = {};

  // per-user
  String? _userId;
  Set<int> _readIds = <int>{};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 1) get current user id
    _userId = await AuthService.getCurrentUserIdOrNull();

    // 2) load read IDs for this user
    _readIds = await NoticeReadStore.getReadIds(userId: _userId);

    // 3) fetch notices and merge flags
    await _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    final response = await _noticeService.fetchNotices();

    if (response.isSuccess && response.responseData is NoticeListModel) {
      final list = response.responseData as NoticeListModel;

      // merge persisted read flags into the fresh list
      list.applyReadFlags(_readIds);

      setState(() {
        _noticeList = list;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.errorMessage ?? 'Failed to load notices';
      });
    }
  }

  Future<void> _onNoticeTap(int noticeId) async {
    // Mark as read locally + persist immediately (good UX)
    await _markNoticeAsRead(noticeId);

    // If already cached, show
    if (_noticeDetailsCache.containsKey(noticeId) &&
        _noticeDetailsCache[noticeId] != null) {
      _showNoticeDetails(context, _noticeDetailsCache[noticeId]!);
      return;
    }

    _showLoadingDialog();

    final response = await _noticeDetailsService.fetchNoticeDetails(noticeId.toString());

    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    if (response.isSuccess && response.responseData is NoticeDetailsModel) {
      final model = response.responseData as NoticeDetailsModel;
      if (model.hasValidNoticeDetail) {
        final detail = model.safeNoticeDetail;
        setState(() {
          _noticeDetailsCache[noticeId] = detail;
        });
        _showNoticeDetails(context, detail);
      }
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Failed to load'),
          content: Text(response.errorMessage ?? 'Something went wrong'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _markNoticeAsRead(int noticeId) async {
    setState(() {
      _noticeList?.markAsRead(noticeId);
      _readIds.add(noticeId);
    });
    await NoticeReadStore.add(noticeId, userId: _userId);
  }

  Future<void> _markNoticeAsUnread(int noticeId) async {
    setState(() {
      _noticeList?.markAsUnread(noticeId);
      _readIds.remove(noticeId);
    });
    await NoticeReadStore.remove(noticeId, userId: _userId);
  }

  Future<void> _markAllAsRead() async {
    final ids = _noticeList?.safeNotices.map((e) => e.safeId) ?? const Iterable<int>.empty();
    setState(() {
      _noticeList?.markAllAsRead();
      _readIds = ids.toSet();
    });
    await NoticeReadStore.setAll(ids, userId: _userId);
  }

  int get _unreadCount {
    final notices = _noticeList?.safeNotices ?? [];
    return notices.where((n) => !n.isRead).length;
  }

  bool _isImageUrl(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.gif') ||
        u.endsWith('.webp') ||
        u.endsWith('.bmp');
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  LoadingWidget(size: 24),
                  SizedBox(width: 12),
                  Text('Loading details...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading
          ? const Center(child: LoadingWidget())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _init,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Header
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
                    '$_unreadCount',
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

          // List
          Expanded(
            child: _noticeList?.hasValidNotices ?? false
                ? ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _noticeList!.safeNotices.length,
              itemBuilder: (context, index) {
                final notice = _noticeList!.safeNotices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NoticeCardWidget(
                    notice: notice,
                    isLoading: false,
                    onTap: () async {
                      await _onNoticeTap(notice.safeId);
                    },
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notices available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for updates',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoticeDetails(BuildContext context, NoticeDetail noticeDetail) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CustomBlobBackground(
              backgroundColor: Colors.white,
              blobColor: AppColor.indigo,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
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

                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            noticeDetail.formattedPublishDate,
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
                        noticeDetail.safeTitle,
                        style: TextStyle(
                          fontSize: Sizes.bodyText(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // HTML description
                      if (noticeDetail.hasValidDescription) ...[
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: Sizes.smallText(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Html(
                          data: noticeDetail.safeDescription,
                          style: {
                            "body": Style(
                              fontSize: FontSize(Sizes.bodyText(context)),
                              color: Colors.black,
                            ),
                          },
                          onLinkTap: (url, context, _) async {
                            if (url == null) return;
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Attachment
                      if (noticeDetail.hasAttachment) ...[
                        Text(
                          'Attachment:',
                          style: TextStyle(
                            fontSize: Sizes.smallText(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isImageUrl(noticeDetail.safeAttachmentUrl))
                          GestureDetector(
                            onTap: () => _openExternal(noticeDetail.safeAttachmentUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                noticeDetail.safeAttachmentUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 180,
                                    alignment: Alignment.center,
                                    child: const LoadingWidget(size: 24),
                                  );
                                },
                                errorBuilder: (ctx, _, __) => Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.broken_image, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Expanded(child: Text('Failed to load image')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => _openExternal(noticeDetail.safeAttachmentUrl),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.primaryColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_file, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      noticeDetail.attachmentFileName,
                                      style: TextStyle(
                                        fontSize: Sizes.normalText(context),
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.open_in_new, size: 16),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
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
          ),
        ),
      ),
    );
  }
}
