import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/course_session_model.dart';
import 'package:medi_exam/data/services/course_session_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';
import 'package:medi_exam/presentation/widgets/session_wise_batch_container.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/shimmer_loading.dart';

class SessionWiseBatchesScreen extends StatefulWidget {
  const SessionWiseBatchesScreen({super.key});

  @override
  State<SessionWiseBatchesScreen> createState() => _SessionWiseBatchesScreenState();
}

class _SessionWiseBatchesScreenState extends State<SessionWiseBatchesScreen> {
  late Map<String, dynamic> sessionWiseBatchesData;
  final CourseSessionService _courseSessionService = CourseSessionService();
  CourseSessionModel? _courseSessionModel;
  late final coursePackageId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    sessionWiseBatchesData = Get.arguments ?? {};
    coursePackageId = (sessionWiseBatchesData['coursePackageId'] ?? '').toString();
    _fetchCourseSessions();
  }

  Future<void> _fetchCourseSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });



    if (coursePackageId.isEmpty) {
      setState(() {
        _errorMessage = 'Invalid course package ID';
        _isLoading = false;
      });
      return;
    }

    final response = await _courseSessionService.fetchCourseSessions(coursePackageId);

    if (response.isSuccess && response.responseData != null) {
      setState(() {
        _courseSessionModel = response.responseData as CourseSessionModel;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.errorMessage ?? 'Failed to load sessions';
        _isLoading = false;
      });
    }
  }

  void _handleSeeAllTap(CourseSession session) {
    Get.toNamed(
      RouteNames.availableBatches,
      arguments: {
        'courseTitle': sessionWiseBatchesData['courseTitle'],
        'disciplineFaculty': sessionWiseBatchesData['title'],
        'coursePackageId': coursePackageId,
        'sessionTitle': session.safeCourseSessionName,
        'icon': sessionWiseBatchesData['icon'],
        'batches': session.batches,
        'isBatch': true,
      },
    );
  }

  void _handleBatchTap(Batch batch) {
    Get.toNamed(
      RouteNames.batchDetails,
      arguments: {
        'batchId': batch.safeId.toString(),
        'coursePackageId': coursePackageId.toString(),
        'imageUrl': batch.safeBannerUrl,
        'time': batch.safeExamTime,
        'days': batch.safeExamDays,
        'days': batch.safeExamDays,
        'startDate': batch.safeStartDate,
        'startDate': batch.safeStartDate,
        'title': batch.safeName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String disciplineFaculty = (sessionWiseBatchesData['title'] ?? '').toString();
    final String courseTitle = (sessionWiseBatchesData['courseTitle'] ?? '').toString();
    final bool isBatch = (sessionWiseBatchesData['isBatch'] is bool) ? sessionWiseBatchesData['isBatch'] : false;
    final iconData = (sessionWiseBatchesData['icon'] is IconData) ? sessionWiseBatchesData['icon'] : Icons.school_rounded;
    final Color colors = isBatch ? AppColor.primaryColor : AppColor.purple;

    return CommonScaffold(
      title: 'Sessions',
      body: RefreshIndicator(
        onRefresh: _fetchCourseSessions,
        color: AppColor.primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Redesigned Header
              HeaderInfoContainer(
                title: courseTitle,
                subtitle: 'Discipline: $disciplineFaculty',
                icon: iconData,
                color: colors,
              ),

              const SizedBox(height: 20),

              // Loading State
              if (_isLoading) _buildLoadingState(),

              // Error State
              if (_errorMessage != null) _buildErrorState(),

              // Empty State
              if (!_isLoading && _errorMessage == null && (_courseSessionModel?.courseSessions?.isEmpty ?? true))
                _buildEmptyState(),

              // Sessions List
              if (!_isLoading && _errorMessage == null && (_courseSessionModel?.courseSessions?.isNotEmpty ?? false))
                _buildSessionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildSessionShimmer();
        },
      ),
    );
  }

  Widget _buildSessionShimmer() {
    return ShimmerLoading(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              Container(
                width: 200,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              // Subtitle shimmer
               Container(
                width: 150,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              // Batch items shimmer
               Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchCourseSessions,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Sessions Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No sessions found for this course package',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return Expanded(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _courseSessionModel!.courseSessions!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final session = _courseSessionModel!.courseSessions![index];
          final batches = session.batches ?? [];

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SessionWiseBatchContainer(
              title: session.safeCourseSessionName,
              subtitle: 'Select your preferred batch',
              isBatch: true,
              batches: batches,
              onTapShowAllBatches: () => _handleSeeAllTap(session),
              onTapBatch: _handleBatchTap,
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              borderColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}