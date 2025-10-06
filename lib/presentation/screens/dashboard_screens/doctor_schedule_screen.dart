import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/doctor_schedule_model.dart';
import 'package:medi_exam/data/services/doctor_schedule_service.dart';
import 'package:medi_exam/main.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/date_section.dart';
import 'package:medi_exam/presentation/widgets/helpers/doctor_schedule_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> with WidgetsBindingObserver, RouteAware{
  final _service = DoctorScheduleService();
  late Map<String, dynamic> args;

  DoctorScheduleModel? _scheduleData;
  bool _loading = true;
  bool _refreshing = false; // NEW: Separate state for background refreshes
  String? _error;

  bool _isPickingDate = false;
  bool _isPrinting = false;

  // Search / filter state
  final TextEditingController _searchCtrl = TextEditingController();
  DateTime? _pickedDate;

  @override
  void initState() {
    super.initState();
    args = Get.arguments ?? {};
    _initialLoad(); // CHANGED: Call initial load instead of fetchSchedule
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Only refresh if we're coming back to this screen
    _refreshData(silent: true); // CHANGED: Use silent refresh
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(silent: true); // CHANGED: Use silent refresh
    }
  }

  // NEW: Separate method for initial load (shows loading)
  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _callApi();
  }

  // NEW: Separate method for background refreshes (no loading)
  Future<void> _refreshData({bool silent = false}) async {
    if (silent) {
      setState(() {
        _refreshing = true;
      });
      await _callApi();
      setState(() {
        _refreshing = false;
      });
    } else {
      // This is for manual pull-to-refresh
      await _callApi();
    }
  }

  // NEW: Pure API call without state management
  Future<void> _callApi() async {
    final String admissionId = (args['admissionId'] ?? '').toString();
    if (admissionId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Admission ID not found.';
      });
      return;
    }

    final response = await _service.fetchDoctorSchedule(admissionId);
    if (!mounted) return;

    if (response.isSuccess) {
      final DoctorScheduleModel model = response.responseData is DoctorScheduleModel
          ? response.responseData as DoctorScheduleModel
          : DoctorScheduleModel.fromJson(
        (response.responseData as Map<String, dynamic>? ?? {}),
      );

      setState(() {
        _scheduleData = model;
        _loading = false;
        _error = null;
      });
    } else {
      setState(() {
        _error = response.errorMessage ?? 'Failed to load schedule.';
        _loading = false;
      });
    }
  }

  // CHANGED: Use refreshData instead of fetchSchedule
  Future<void> _refresh() async {
    await _refreshData(silent: false);
  }

  List<ScheduleDate> get _filteredDates {
    final model = _scheduleData;
    if (model == null) return const [];

    final q = _searchCtrl.text.trim().toLowerCase();
    final hasQuery = q.isNotEmpty;
    final hasDate = _pickedDate != null;

    bool matchesDate(ScheduleDate d) {
      if (!hasDate) return true;
      // Compare yyyy-mm-dd prefix of ISO date
      final iso = d.safeDate;
      if (iso.isEmpty) return false;
      try {
        final parsed = DateTime.parse(iso);
        return parsed.year == _pickedDate!.year &&
            parsed.month == _pickedDate!.month &&
            parsed.day == _pickedDate!.day;
      } catch (_) {
        return false;
      }
    }

    bool matchesQuery(ScheduleDate d) {
      if (!hasQuery) return true;
      final inHeader = (d.safeDateFormatted + ' ' + d.safeTime).toLowerCase();
      if (inHeader.contains(q)) return true;

      // Look into content topic names
      for (final c in d.safeContents) {
        if (c.safeTopicName.toLowerCase().contains(q)) return true;
      }
      return false;
    }

    final dates = model.safeScheduleDates.where((d) {
      return matchesDate(d) && matchesQuery(d);
    }).toList();

    return dates;
  }

  // ===== NEW: helpers for "Today" section =====
  ScheduleDate? get _todaySchedule {
    final model = _scheduleData;
    if (model == null) return null;

    final now = DateTime.now();
    for (final d in model.safeScheduleDates) {
      final iso = d.safeDate;
      if (iso.isEmpty) continue;
      try {
        final dt = DateTime.parse(iso);
        if (_isSameYMD(dt, now)) return d;
      } catch (_) {
        // ignore bad dates
      }
    }
    return null;
  }

  bool _isSameYMD(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _onPrintPressed() async {
    if (_isPrinting) return; // guard
    setState(() => _isPrinting = true);

    try {
      final bytes = await _buildSchedulePdf();
      final fileTitle = _fileTitleForPdf();
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: '$fileTitle-Schedule.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'Print failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  String _fileTitleForPdf() {
    final b = _scheduleData?.batch;
    final raw = (b?.batchName?.isNotEmpty ?? false)
        ? b!.batchName!
        : (b?.courseName?.isNotEmpty ?? false)
        ? b!.courseName!
        : 'Batch';
    // sanitize for file name
    return raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Future<Uint8List> _buildSchedulePdf() async {
    final pdf = pw.Document();

    // Styles (monochrome, simple)
    final titleStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    final h2Style = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
    final labelStyle = pw.TextStyle(fontSize: 10, color: PdfColors.grey700);
    final valueStyle = pw.TextStyle(fontSize: 11);
    final dateStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    final itemStyle = pw.TextStyle(fontSize: 11, color: PdfColors.black);

    final batch = _scheduleData?.batch;
    final dates = _scheduleData?.safeScheduleDates ?? const <ScheduleDate>[];



    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 36),

        // Header
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
              pw.Text(_formatNowStamp(), style: labelStyle, textAlign: pw.TextAlign.right),
            ],
          ),
        ),

        // Body
        build: (ctx) => [
          // Batch info (minimal, no status)
          if (batch != null) ...[
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
                  if ((batch.batchName?.isNotEmpty ?? false) ||
                      (batch.courseName?.isNotEmpty ?? false))
                    pw.Text(
                      (batch.batchName?.isNotEmpty ?? false)
                          ? batch.batchName!
                          : batch.courseName!,
                      style: h2Style,
                    ),
                  pw.SizedBox(height: 6),
                  pw.Row(children: [
                    if (batch.coursePackageName?.isNotEmpty ?? false) ...[
                      pw.Text('Discipline/Faculty: ', style: labelStyle),
                      pw.Text(batch.coursePackageName!, style: valueStyle),
                    ]
                  ]),
                  pw.SizedBox(height: 6),
                  pw.Row(children: [
                    if (batch.year?.isNotEmpty ?? false) ...[
                      pw.Text('Session: ', style: labelStyle),
                      pw.Text(batch.year!, style: valueStyle),
                      pw.SizedBox(width: 8),
                    ],
                    if (batch.regNo?.isNotEmpty ?? false) ...[
                      pw.Text('Reg No: ', style: labelStyle),
                      pw.Text(batch.regNo!, style: valueStyle),
                    ],
                  ]),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 14),

          if (dates.isEmpty)
            pw.Text('No schedule is available yet.', style: valueStyle)
          else
            ...dates.map((d) => _pdfDateSection(d, dateStyle, itemStyle)).toList(),
        ],

        // Footer
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
            ),
          ),
          child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: labelStyle),
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfDateSection(
      ScheduleDate date,
      pw.TextStyle dateStyle,
      pw.TextStyle itemStyle,
      ) {
    final String dateText = date.safeDateFormatted;
    final String timeText = date.safeTime.trim();
    final contents = date.safeContents;

    // We only show: Date header, then "Exam: <topic>" and "Video: <solve-name>"
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Date + time
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(dateText, style: dateStyle),
              if (timeText.isNotEmpty) ...[
                pw.SizedBox(width: 6),
                pw.Text(
                  '- $timeText',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
              ],
            ],
          ),
          pw.SizedBox(height: 6),

          // Items (exam titles + video titles only)
          if (contents.isEmpty)
            pw.Text('— No items for this date', style: itemStyle)
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: contents.expand((c) {
                final lines = <pw.Widget>[];

                // Exam title
                final examTitle = c.safeTopicName;
                if (examTitle.isNotEmpty) {
                  lines.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('* ', style: itemStyle),
                          pw.Expanded(child: pw.Text('Exam: $examTitle', style: itemStyle)),
                        ],
                      ),
                    ),
                  );
                }

                // Video titles (solve links)
                final solveNames = c.safeSolveLinks
                    .map((e) => e.safeName)
                    .where((s) => s.isNotEmpty)
                    .toList();
                for (final v in solveNames) {
                  lines.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 2, left: 14),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('* ', style: itemStyle),
                          pw.Expanded(child: pw.Text('Video: $v', style: itemStyle)),
                        ],
                      ),
                    ),
                  );
                }

                return lines;
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatNowStamp() {
    final now = DateTime.now();
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${now.year}-${two(now.month)}-${two(now.day)}  ${two(now.hour)}:${two(now.minute)}';
  }

  Future<void> _pickDate() async {
    if (_isPickingDate) return;
    setState(() => _isPickingDate = true);
    try {
      final now = DateTime.now();
      final initial = _pickedDate ?? now;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(now.year - 3),
        lastDate: DateTime(now.year + 3),
      );
      if (!mounted) return;
      if (picked != null) setState(() => _pickedDate = picked);
    } finally {
      if (mounted) setState(() => _isPickingDate = false);
    }
  }

  void _clearDate() => setState(() => _pickedDate = null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dates = _filteredDates;
    final batch = _scheduleData?.batch;
    final hasQuery = _searchCtrl.text.trim().isNotEmpty;
    final hasPickedDate = _pickedDate != null;
    final ScheduleDate? todayDate = _todaySchedule;


    return CommonScaffold(
      title: 'Schedule',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: theme.colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                // Loading state
                if (_loading)
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 420,
                      child: Center(),
                    ),
                  )

                // Error state
                else if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: ErrorView(
                        message: _error!,
                        onRetry: _refresh,
                      ),
                    ),
                  )

                // Content when loaded
                else if (_scheduleData != null && !_scheduleData!.isEmpty) ...[
                    // --- Top: Batch info card (only when completed) ---
                    if (batch != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: BatchInfoCardCompact(batch: batch),
                        ),
                      ),

                    // === NEW: "Today" section ===
                    if (!hasQuery && !hasPickedDate)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: TodaySectionCard(
                            todayDate: todayDate,
                            admissionId: batch?.admissionId ?? '',
                          ),
                        ),
                      ),


                    // --- Search + Calendar + Print row ---
                    // === NEW: Card that contains "Full schedule" header + Search row + List ===
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.primaryColor.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: only show when no filters are active
                                if (!hasQuery && !hasPickedDate) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.event_note_rounded,
                                          size: 18, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Full schedule',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Search + Calendar + Print row (unchanged)
                                SearchActionsRow(
                                  controller: _searchCtrl,
                                  pickedDate: _pickedDate,
                                  onChanged: (_) => setState(() {}),
                                  onTapCalendar: _pickDate,
                                  onTapClearDate: _clearDate,
                                  onTapPrint: _onPrintPressed,
                                  isCalendarLoading: _isPickingDate,
                                  isPrintLoading: _isPrinting,
                                ),

                                const SizedBox(height: 12),

                                // Results inside the same card
                                if (dates.isEmpty)
                                  const NoMatchesView()
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: dates.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final date = dates[index];
                                      return DateSection(
                                        scheduleDate: date,
                                        admissionId: batch!.admissionId ?? '',
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]

                  // Empty state
                  else
                    SliverToBoxAdapter(
                      child: EmptyView(onRetry: _refresh),
                    ),
              ],
            ),
          ),

          // Loading overlay (kept)
          if (_loading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Center(child: LoadingWidget()),
              ),
            ),
        ],
      ),
    );
  }
}
