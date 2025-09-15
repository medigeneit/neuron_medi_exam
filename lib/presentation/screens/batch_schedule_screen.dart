// batch_schedule_screen.dart
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/batch_schedule_model.dart';
import 'package:medi_exam/data/services/batch_schedule_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/responsive.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/animated_gradient_button.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/date_formatter_widget.dart';
import 'package:medi_exam/presentation/widgets/helpers/banner_card_helpers.dart';
import 'package:medi_exam/presentation/widgets/hero_header_with_image.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/print_button_widget.dart';
import 'package:medi_exam/presentation/widgets/schedule_date_section.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BatchScheduleScreen extends StatefulWidget {
  const BatchScheduleScreen({Key? key}) : super(key: key);

  @override
  State<BatchScheduleScreen> createState() => _BatchScheduleScreenState();
}

class _BatchScheduleScreenState extends State<BatchScheduleScreen> {
  final _service = BatchScheduleService();

  bool _isLoading = true;
  String _errorMessage = '';
  BatchScheduleModel? _schedule;

  // From arguments (if provided)
  late String batchId;
  late String batchPackageId;
  late String coursePackageId;
  late String imageUrl;
  late String title;
  late String subTitle;
  late String time;
  late String days;
  late String startDate;

  @override
  void initState() {
    super.initState();
    _extractArguments();
    _fetchSchedule();
  }

  void _extractArguments() {
    final args = Get.arguments ?? {};
    batchId = args['batchId']?.toString() ?? '';
    batchPackageId = args['batchPackageId']?.toString() ?? '';
    coursePackageId = args['coursePackageId']?.toString() ?? '';
    imageUrl = args['imageUrl']?.toString() ?? '';
    time = args['time']?.toString() ?? '';
    days = args['days']?.toString() ?? '';
    startDate = args['startDate']?.toString() ?? '';
    title = args['title']?.toString() ?? '';
    subTitle = args['subTitle']?.toString() ?? '';
  }

  Future<void> _fetchSchedule() async {
    if (batchPackageId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Missing batchPackageId';
      });
      return;
    }

    // ✅ use the actual batchPackageId (was hardcoded "3")
    final response = await _service.fetchBatchSchedule('3');
    if (!mounted) return;

    if (response.isSuccess && response.responseData is BatchScheduleModel) {
      setState(() {
        _schedule = response.responseData as BatchScheduleModel;
        _isLoading = false;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.errorMessage ?? 'Failed to load schedule';
      });
    }
  }


  Future<void> _onPrintPressed() async {
    try {
      final bytes = await _buildSchedulePdf();
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Batch_Schedule.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'Print failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  Future<Uint8List> _buildSchedulePdf() async {
    final pdf = pw.Document();

    // ----- Gather header data (same logic you use in UI) -----
    final Batch? batch = _schedule?.batch;
    final String headerTitle = (title.isNotEmpty)
        ? title
        : (batch?.hasValidCoursePackageName ?? false)
        ? batch!.safeCoursePackageName
        : 'Batch';

    final String headerSubtitle = (subTitle.isNotEmpty)
        ? subTitle
        : (batch?.hasValidCoursePackageName ?? false)
        ? batch!.safeCoursePackageName
        : '';

    final String headerDays = days;
    final String headerTime = time;
    final String headerStartDate = startDate;

    final dates = _schedule?.scheduleDates ?? const <ScheduleDate>[];

    // ----- Styles (monochrome) -----
    final titleStyle    = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    final h2Style       = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
    final labelStyle    = pw.TextStyle(fontSize: 10, color: PdfColors.grey700);
    final valueStyle    = pw.TextStyle(fontSize: 11);
    final dateStyle     = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    final itemStyle     = pw.TextStyle(fontSize: 11, color: PdfColors.black);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 36),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
            ),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Batch Schedule', style: titleStyle),
                ],
              ),
              pw.Text(
                _formatNow(), // generated timestamp
                style: labelStyle,
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ),
        build: (ctx) => [
          // ------- Batch Info (header) -------
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
              color: PdfColors.white,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (headerTitle.isNotEmpty)
                  pw.Text(headerTitle, style: h2Style),
                pw.SizedBox(height: 6),

                pw.Row(
                  children: [
                    if (headerSubtitle.isNotEmpty) ...[
                      pw.Text('Discipline/Faculty: ', style: labelStyle),
                      pw.Text(headerSubtitle, style: valueStyle),
                      pw.SizedBox(width: 6),
                    ]
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    if (headerDays.isNotEmpty) ...[
                      pw.Text('Days: ', style: labelStyle),
                      pw.Text(headerDays, style: valueStyle),
                      pw.SizedBox(width: 6),
                    ],
                    if (headerTime.isNotEmpty) ...[
                      pw.Text('Time: ', style: labelStyle),
                      pw.Text(headerTime, style: valueStyle),
                      pw.SizedBox(width: 6),
                    ],
                    if (headerStartDate.isNotEmpty) ...[
                      pw.Text('Start Date: ', style: labelStyle),
                      pw.Text(headerStartDate, style: valueStyle),
                    ],
                  ],
                )

              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // ------- Schedule list -------
          if (dates.isEmpty)
            pw.Text('No schedule is available yet.', style: valueStyle)
          else
            ...dates.map((d) => _dateSection(d, dateStyle, itemStyle)).toList(),
        ],
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
            ),
          ),
          child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: labelStyle),
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _dateSection(
      ScheduleDate date,
      pw.TextStyle dateStyle,
      pw.TextStyle itemStyle,
      ) {
    final String dateText = date.safeDateFormatted;
    final String timeText = (date.safeTime ?? '').trim(); // show if present
    final contents = date.safeContents;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Date + time (monochrome)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(dateText, style: dateStyle),
              if (timeText.isNotEmpty) ...[
                pw.SizedBox(width: 6),
                pw.Text('- $timeText',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    )),
              ],
            ],
          ),
          pw.SizedBox(height: 6),

          // Items
          if (contents.isEmpty)
            pw.Text('— No items for this date', style: itemStyle)
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: contents.map((c) {
                final type = c.isExam ? '[Exam]' : '[Solve]';
                final title = c.safeTopicName;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('', style: itemStyle), // bullet restored
                      pw.Expanded(
                        child: pw.Text('$type  $title', style: itemStyle),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    // Simple local stamp; adjust to your preferred format or locale
    return '${now.year}-${_two(now.month)}-${_two(now.day)}  ${_two(now.hour)}:${_two(now.minute)}';
  }

  String _two(int v) => v < 10 ? '0$v' : '$v';



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isMobile = Responsive.isMobile(context);
    final gradientColors = [AppColor.indigo, AppColor.purple];
    final gradientButtonColors = [Colors.purple, Colors.blue];

    final Batch? batch = _schedule?.batch;
    final String banner = (imageUrl.isNotEmpty)
        ? imageUrl
        : (batch?.hasValidBannerUrl ?? false)
        ? batch!.bannerUrl!
        : '';

    final String headerTitle = (title.isNotEmpty)
        ? title
        : (batch?.hasValidCoursePackageName ?? false)
        ? batch!.safeCoursePackageName
        : 'Batch';

    final String headerSubtitle = (subTitle.isNotEmpty)
        ? subTitle
        : (batch?.hasValidCoursePackageName ?? false)
        ? batch!.safeCoursePackageName
        : '';

    final dates = _schedule?.scheduleDates ?? const <ScheduleDate>[];
    final hasDates = dates.isNotEmpty;

    return CommonScaffold(
      title: 'Batch Schedule',
      body: RefreshIndicator(
        onRefresh: _fetchSchedule,
        edgeOffset: 120,
        child: Stack(
          children: [
            if (_isLoading)
              const Center(child: LoadingWidget())
            else if (_errorMessage.isNotEmpty)
              _ErrorState(message: _errorMessage, onRetry: _fetchSchedule)
            else
            // Main Scroll
              CustomScrollView(
                slivers: [
                  // Collapsible hero with image like BatchDetailsScreen
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 0,
                    collapsedHeight: 0,
                    pinned: false,
                    stretch: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    expandedHeight: isMobile ? 260 : 360,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: HeroHeader(
                        banner: banner,
                        headerTitle: headerTitle,
                        headerSubtitle: headerSubtitle,
                        time: time,
                        days: days,
                        startDate: startDate,
                      ),
                    ),
                  ),

                  // section title chip (optional)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isDark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.04),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.12)
                                        : Colors.black.withOpacity(0.06),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.schedule_rounded, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Schedule',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Top-right print action (only when data is ready)
                          if (!_isLoading && _errorMessage.isEmpty)
                            PrintButton(onPressed: _onPrintPressed),
                        ],
                      ),
                    ),
                  ),

                  // Content: Schedule dates OR empty state
                  if (hasDates)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                      sliver: SliverList.separated(
                        itemCount: dates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          return ScheduleDateSection(scheduleDate: date);
                        },
                      ),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
                        child: _EmptyState(
                          onRefresh: _fetchSchedule,
                          title: 'No schedule is available yet',
                          subtitle:
                          'We’ll publish the schedule soon. Please check back later.',
                        ),
                      ),
                    ),
                ],
              ),

            // CTA (Enroll Now) pinned at bottom like in BatchDetailsScreen
            if (!_isLoading && _errorMessage.isEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: GradientCTA(
                  colors: gradientButtonColors,
                  onTap: () {
                    // Same behavior as BatchDetailsScreen
                    final paymentData = {
                      'batchId': batchId,
                      'coursePackageId': coursePackageId,
                      'title': headerTitle,
                      'subTitle': headerSubtitle,
                      'imageUrl': banner,
                      'time': time,
                      'days': days,
                      'startDate': startDate,
                    };
                    Get.toNamed(RouteNames.makePayment, arguments: paymentData);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}



class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 56,
              color:
              (isDark ? Colors.white : Colors.black).withOpacity(0.30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:
                (isDark ? Colors.white : Colors.black).withOpacity(0.55),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black87,
                elevation: 0,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}







