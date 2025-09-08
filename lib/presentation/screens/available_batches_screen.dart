import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/course_session_model.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/available_banner_card.dart';
import 'package:medi_exam/presentation/widgets/available_screens_helpers.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';

class AvailableBatchesScreen extends StatefulWidget {
  const AvailableBatchesScreen({Key? key}) : super(key: key);

  @override
  State<AvailableBatchesScreen> createState() => _AvailableBatchesScreenState();
}

class _AvailableBatchesScreenState extends State<AvailableBatchesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Variables to store the passed arguments
  late String courseTitle;
  late String disciplineFaculty;
  late final coursePackageId;
  late String sessionTitle;
  late List<Batch> batches;
  late IconData icon;
  late bool isBatch;

  String _query = '';

  @override
  void initState() {
    super.initState();

    // Retrieve the arguments passed from the previous screen
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};

    courseTitle = arguments['courseTitle'] ?? 'Available Batches';
    disciplineFaculty = arguments['disciplineFaculty'] ?? '';
    coursePackageId = (arguments['coursePackageId'] ?? '').toString();
    sessionTitle = arguments['sessionTitle'] ?? '';
    icon = (arguments['icon'] is IconData) ? arguments['icon'] : Icons.school_rounded;
    batches = (arguments['batches'] as List<Batch>?) ?? [];
    isBatch = arguments['isBatch'] ?? true;

    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.trim();
      if (q != _query) {
        setState(() => _query = q);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Batch> get _filtered {
    if (_query.isEmpty) return batches;
    final q = _query.toLowerCase();
    return batches.where((batch) {
      return batch.safeName.toLowerCase().contains(q) ||
          batch.safeExamDays.toLowerCase().contains(q) ||
          batch.safeExamTime.toLowerCase().contains(q) ||
          batch.formattedStartDate.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 380;
    final Color colors = isBatch ? AppColor.primaryColor : AppColor.purple;

    return CommonScaffold(
      title: 'Available Batches',
      body: Column(
        children: [
          // ---- Information header with passed data ----
          if (disciplineFaculty.isNotEmpty || sessionTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HeaderInfoContainer(
                title: courseTitle,
                subtitle: 'Discipline/Faculty: $disciplineFaculty',
                additionalText: sessionTitle.isNotEmpty ? 'Session: $sessionTitle' : null,
                color: colors,
                icon: icon,
              ),
            ),

          // ---- top app/search area ----
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: SearchBarWidget(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              isCompact: isCompact,
              onClear: () {
                _searchCtrl.clear();
                _searchFocus.requestFocus();
              },
              onSubmitted: (_) {
                _searchFocus.unfocus();
              },
            ),
          ),

          // small helper/status row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                if (_query.isEmpty)
                  TinyChip(
                    icon: Icons.explore_rounded,
                    label: 'Showing ${batches.length} batches',
                  )
                else
                  TinyChip(
                    icon: Icons.search_rounded,
                    label: '${_filtered.length} match${_filtered.length == 1 ? '' : 'es'} for "$_query"',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ---- list ----
          Expanded(
            child: _filtered.isEmpty
                ? EmptyState(query: _query)
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = _filtered[index];
                return AvailableBannerCard(
                  batch: batch,
                  onDetails: () {
                    _navigateToBatchDetails(batch);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBatchDetails(Batch batch) {
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

}