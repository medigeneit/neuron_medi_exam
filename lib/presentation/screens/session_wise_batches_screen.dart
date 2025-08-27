import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/available_batch_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/header_info_container.dart';
import 'package:medi_exam/presentation/widgets/session_wise_batch_container.dart';

class SessionWiseBatchesScreen extends StatefulWidget {
  const SessionWiseBatchesScreen({super.key});

  @override
  State<SessionWiseBatchesScreen> createState() => _SessionWiseBatchesScreenState();
}

class _SessionWiseBatchesScreenState extends State<SessionWiseBatchesScreen> {
  late Map<String, dynamic> sessionWiseBatchesData;

  @override
  void initState() {
    super.initState();
    sessionWiseBatchesData = Get.arguments ?? {};
  }

  void _handleSeeAllTap(Map<String, dynamic> session) {
    Get.toNamed(
      RouteNames.availableBatches,
      arguments: {
        'courseTitle': sessionWiseBatchesData['courseTitle'],
        'disciplineFaculty': sessionWiseBatchesData['title'],
        'sessionTitle': session['title'],
        'icon': sessionWiseBatchesData['icon'],
        'items': session['items'],
        'isBatch': true,
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
      body: Padding(
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

            // Sessions (no expand/collapse)
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: DemoBatchData.sessionData.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = DemoBatchData.sessionData[index];
                  final items = (session['items'] as List<AvailableBatchItem>);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SessionWiseBatchContainer(
                      title: session['title'],
                      subtitle: session['subtitle'],
                      isBatch: isBatch,
                      items: items,
                      onTapShowAllBatches: () => _handleSeeAllTap(session),
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      borderColor: Colors.transparent,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}