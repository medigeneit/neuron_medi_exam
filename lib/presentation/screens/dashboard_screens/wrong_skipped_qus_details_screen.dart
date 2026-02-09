import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/wrong_skipped_qus_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';

import 'package:medi_exam/presentation/widgets/wrong_skipped_widgets.dart';

class WrongSkippedQusDetailsScreen extends StatefulWidget {
  const WrongSkippedQusDetailsScreen({super.key});

  @override
  State<WrongSkippedQusDetailsScreen> createState() =>
      _WrongSkippedQusDetailsScreenState();
}

class _WrongSkippedQusDetailsScreenState extends State<WrongSkippedQusDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final WrongSkippedQusModel _model;

  static const _tabs = <_TabMeta>[
    _TabMeta(
      keyName: 'batch',
      title: 'Enrolled courses exams performance',
      icon: Icons.school_rounded,
    ),
    _TabMeta(
      keyName: 'open',
      title: 'Course-wise free exams performance',
      icon: Icons.auto_stories_rounded,
    ),
    _TabMeta(
      keyName: 'free',
      title: 'Customized free exams performance',
      icon: Icons.tune_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    final args = Get.arguments;
    if (args is WrongSkippedQusModel) {
      _model = args;
    } else {
      _model = WrongSkippedQusModel.parse(args);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  WrongSkippedExamTypeSummary? _summaryOf(String typeKey) {
    final map = _model.typeSummary;
    if (map == null) return null;

    // try direct key
    if (map.containsKey(typeKey)) return map[typeKey];

    // fallback: find by examType in values
    for (final e in map.entries) {
      final v = e.value;
      final t = (v.examType ?? '').trim().toLowerCase();
      if (t == typeKey) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Wrong & Skipped',
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Tabs (match your enrolled courses style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.18)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(6),
                labelColor: AppColor.primaryColor,
                unselectedLabelColor:
                AppColor.secondaryColor.withOpacity(0.75),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: Sizes.smallText(context),
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: Sizes.smallText(context),
                ),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.school_rounded, size: 18),
                      child: Center(
                        child: Text(
                          'Enrolled\nCourses Exam',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.verySmallText(context), // ✅ smaller
                            fontWeight: FontWeight.w700,
                            height: 1.05, // ✅ compact line height
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      icon: const Icon(Icons.auto_stories_rounded, size: 18),
                      child: Center(
                        child: Text(
                          'Course-wise\nFree Exam',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.verySmallText(context),
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      child: Center(
                        child: Text(
                          'Customized\nFree Exam',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.verySmallText(context),
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                  ],

              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((t) {
                final summary = _summaryOf(t.keyName);
                return _buildTab(
                  context,
                  meta: t,
                  summary: summary,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, {
        required _TabMeta meta,
        required WrongSkippedExamTypeSummary? summary,
      }) {
    final items = summary?.items ?? const <WrongSkippedExamSummaryItem>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      physics: const BouncingScrollPhysics(),
      children: [
        WrongSkippedTypeHeaderCard(
          title: meta.title,
          icon: meta.icon,
          summary: summary,
        ),
        const SizedBox(height: 12),

        if (items.isEmpty)
          _EmptyStateCard(
            title: 'No exams found',
            subtitle: 'There is no data for this section yet.',
            icon: meta.icon,
          )
        else
          ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.list_alt_rounded,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Exams',
                    style: TextStyle(
                      fontSize: Sizes.normalText(context),
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: Sizes.smallText(context),
                      fontWeight: FontWeight.w800,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WrongSkippedExamListItem(
                  item: e,
                  onTap: () => _navigateNextScreen(metaKey: meta.keyName, item: e),
                ),
              );
            }),
          ],
      ],
    );
  }

  void _navigateNextScreen({
    required String metaKey,
    required WrongSkippedExamSummaryItem item,
  }) {
    // 1) Decide type
    final type = (item.examType ?? metaKey).toString().trim();

    // 2) Decide examId (special rules)
    final meta = item.meta ?? <String, dynamic>{};

    String? resolvedExamId;

    if (type.toLowerCase() == 'open') {
      // open -> meta.doctor_open_exam_id
      final v = meta['doctor_open_exam_id'];
      resolvedExamId = v?.toString();
    } else if (type.toLowerCase() == 'batch') {
      // batch -> meta.doctor_exam_id
      final v = meta['doctor_exam_id'];
      resolvedExamId = v?.toString();
    }

    // fallback -> item.examId
    resolvedExamId ??= item.examId?.toString();

    final args = <String, dynamic>{
      'title': item.examTitle ?? 'Exam',
      'type': type,
      'examId': resolvedExamId ?? '',
    };

    Get.toNamed(
      RouteNames.wrongSkippedQuestions,
      arguments: args,
      preventDuplicates: true,
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: Sizes.bodyText(context),
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.smallText(context),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabMeta {
  final String keyName;
  final String title;

  final IconData icon;

  const _TabMeta({
    required this.keyName,
    required this.title,

    required this.icon,
  });
}
