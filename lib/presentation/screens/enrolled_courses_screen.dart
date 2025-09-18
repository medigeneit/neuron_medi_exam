import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/data/models/all_enrolled_batches_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/enrolled_courses_card_widget.dart';

class EnrolledCoursesScreen extends StatefulWidget {
  const EnrolledCoursesScreen({super.key});

  @override
  State<EnrolledCoursesScreen> createState() => _EnrolledCoursesScreenState();
}

class _EnrolledCoursesScreenState extends State<EnrolledCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Full list and buckets
  late final List<EnrolledBatch> _all;
  late final List<EnrolledBatch> _active;   // payment_status == completed
  late final List<EnrolledBatch> _unpaid;   // payment_status == No Payment
  late final List<EnrolledBatch> _previous; // payment_status == previous

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Parse the navigation argument(s)
    final args = Get.arguments;
    _all = _parseArgs(args);

    // Split into tabs by payment_status
    String norm(String? s) => (s ?? '').trim().toLowerCase();
    _active   = _all.where((b) => norm(b.paymentStatus) == 'completed').toList();
    _unpaid   = _all.where((b) => norm(b.paymentStatus) == 'no payment').toList();
    _previous = _all.where((b) => norm(b.paymentStatus) == 'previous').toList();
  }

  List<EnrolledBatch> _parseArgs(dynamic a) {
    if (a == null) return <EnrolledBatch>[];

    if (a is List<EnrolledBatch>) return a;

    if (a is AllEnrolledBatchesModel) {
      return a.enrolledBatches ?? <EnrolledBatch>[];
    }

    if (a is List) {
      // Be generous and convert from maps if needed
      return a.map<EnrolledBatch?>((e) {
        if (e is EnrolledBatch) return e;
        if (e is Map<String, dynamic>) return EnrolledBatch.fromJson(e);
        if (e is Map) {
          return EnrolledBatch.fromJson(Map<String, dynamic>.from(e));
        }
        return null;
      }).whereType<EnrolledBatch>().toList();
    }

    return <EnrolledBatch>[];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Enrolled Courses',
      body: Column(
        children: [
          // Tab Bar
          Container(
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(6),
              labelColor: AppColor.primaryColor,
              unselectedLabelColor: AppColor.secondaryColor.withOpacity(0.7),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.normalText(context),
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Sizes.normalText(context),
              ),
              tabs: const [
                Tab(
                  text: 'Active',
                  icon: Icon(Icons.play_circle_fill_rounded, size: 20),
                ),
                Tab(
                  text: 'Unpaid',
                  icon: Icon(Icons.payment_rounded, size: 20),
                ),
                Tab(
                  text: 'Previous',
                  icon: Icon(Icons.history_rounded, size: 20),
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active (completed)
                _buildCourseList(
                  courses: _active,
                  emptyMessage: 'No active courses found',
                  emptyIcon: Icons.play_circle_outline_rounded,
                ),

                // Unpaid (No Payment)
                _buildCourseList(
                  courses: _unpaid,
                  emptyMessage: 'No unpaid courses',
                  emptyIcon: Icons.payment_outlined,
                ),

                // Previous
                _buildCourseList(
                  courses: _previous,
                  emptyMessage: 'No previous courses',
                  emptyIcon: Icons.history_toggle_off_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList({
    required List<EnrolledBatch> courses,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: Sizes.bodyText(context),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore our courses to get started',
              style: TextStyle(
                fontSize: Sizes.smallText(context),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final batch = courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EnrolledCourseCard(batch: batch), // ← uses real model
        );
      },
    );
  }
}
