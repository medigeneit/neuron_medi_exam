// lib/presentation/screens/dashboard.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:medi_exam/main.dart'; // ✅ routeObserver

import 'package:medi_exam/data/models/all_enrolled_batches_model.dart';
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/models/free_exam_list_model.dart';
import 'package:medi_exam/data/models/wrong_skipped_qus_model.dart';
import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/data/network_response.dart';

import 'package:medi_exam/data/services/all_enrolled_batches_service.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/services/free_exam_list_service.dart';
import 'package:medi_exam/data/services/wrong_skipped_qus_service.dart';
import 'package:medi_exam/data/utils/urls.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/dashboard_section_helpers.dart';
import 'package:medi_exam/presentation/widgets/enrolled_courses_card_widget.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';
import 'package:medi_exam/presentation/widgets/free_exam_item_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/notification_bell.dart';
import 'package:medi_exam/presentation/widgets/question_action_row.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with WidgetsBindingObserver, RouteAware {
  final AllEnrolledBatchesService _service = AllEnrolledBatchesService();
  late Future<List<EnrolledBatch>> _batchesFuture;

  bool _hasUnreadNotifications = false;
  bool _refreshing = false;

  bool _subscribed = false;

  // Add this variable to store the wrong/skipped model
  WrongSkippedQusModel? _wrongSkippedModel;

  // ✅ Scroll controller to detect scroll position
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Preload favourites ONCE (no await needed)
    Future.microtask(() => GlobalFavouriteCache.ensureLoaded());

    _batchesFuture = _loadBatches();

    // ✅ Listen to scroll events
    _scrollController.addListener(_onScroll);

    // ✅ Check initial scroll position after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollIndicator();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _silentRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefresh();
    }
  }

  // ✅ Scroll listener
  void _onScroll() {
    _checkScrollIndicator();
  }

  // ✅ Check if user can scroll more
  void _checkScrollIndicator() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 50;

    if (atBottom != !_showScrollIndicator) {
      setState(() {
        _showScrollIndicator = !atBottom;
      });
    }
  }

  // ✅ Tap action: scroll down (one "screen" / viewport)
  Future<void> _scrollDownOnTap() async {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // Scroll down ~85% of the visible height
    final step = position.viewportDimension * 0.85;
    final target = math.min(position.pixels + step, position.maxScrollExtent);

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  // If you want tap to go straight to bottom, use this instead:
  // Future<void> _scrollToBottom() async {
  //   if (!_scrollController.hasClients) return;
  //   await _scrollController.animateTo(
  //     _scrollController.position.maxScrollExtent,
  //     duration: const Duration(milliseconds: 650),
  //     curve: Curves.easeOutCubic,
  //   );
  // }

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    setState(() => _refreshing = true);

    // recreate the Future so FutureBuilder rebuilds silently
    setState(() => _batchesFuture = _loadBatches());

    try {
      await _batchesFuture;
    } catch (_) {}

    if (mounted) setState(() => _refreshing = false);
  }

  Future<List<EnrolledBatch>> _loadBatches() async {
    final response = await _service.fetchAllEnrolledBatches();
    if (response.isSuccess == true && response.responseData != null) {
      final AllEnrolledBatchesModel model =
      response.responseData is AllEnrolledBatchesModel
          ? response.responseData
          : AllEnrolledBatchesModel.fromJson(
        response.responseData as List<dynamic>,
      );
      return model.enrolledBatches ?? <EnrolledBatch>[];
    }
    return <EnrolledBatch>[];
  }

  EnrolledBatch? _pickHighlight(List<EnrolledBatch> items) {
    String norm(String? s) => (s ?? '').trim().toLowerCase();

    EnrolledBatch? firstBy(String wanted) {
      for (final b in items) {
        if (norm(b.paymentStatus) == wanted) return b;
      }
      return null;
    }

    return firstBy('completed') ?? firstBy('no payment') ?? firstBy('previous');
  }

  // Method to update the model from DashboardWrongSkippedSection
  void _updateWrongSkippedModel(WrongSkippedQusModel? model) {
    if (mounted) {
      setState(() {
        _wrongSkippedModel = model;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset + 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: Sizes.subTitleText(context),
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Continue your learning journey',
                          style: TextStyle(
                            fontSize: Sizes.normalText(context),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    NotificationBell(
                      hasUnread: _hasUnreadNotifications,
                      onTap: () {
                        Get.snackbar(
                          'No Notifications',
                          "you don't have any notifications right now",
                          backgroundColor: AppColor.indigo,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Enrolled Courses
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enrolled Courses',
                              style: TextStyle(
                                fontSize: Sizes.bodyText(context),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            FutureBuilder<List<EnrolledBatch>>(
                              future: _batchesFuture,
                              builder: (context, snap) {
                                final loaded = snap.connectionState ==
                                    ConnectionState.done;
                                final items =
                                    snap.data ?? const <EnrolledBatch>[];

                                return OutlinedButton(
                                  onPressed: loaded && items.isNotEmpty
                                      ? () {
                                    Get.toNamed(
                                      RouteNames.enrolledCourses,
                                      arguments: items,
                                    );
                                  }
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColor.primaryColor,
                                    side: BorderSide(
                                      color: AppColor.primaryColor
                                          .withOpacity(0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: const Text(
                                    'See All',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<EnrolledBatch>>(
                          future: _batchesFuture,
                          builder: (context, snapshot) {
                            final isWaiting = snapshot.connectionState ==
                                ConnectionState.waiting;

                            final items =
                                snapshot.data ?? const <EnrolledBatch>[];

                            if (isWaiting && items.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                alignment: Alignment.center,
                                child: const LoadingWidget(),
                              );
                            }

                            final firstActiveCourse = _pickHighlight(items);

                            if (firstActiveCourse != null) {
                              return EnrolledCourseCard(batch: firstActiveCourse);
                            }

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No active courses',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Customized Exam section
                DashboardCustomizedExamSection(
                  maxItems: 1,
                  showSeeAll: true,
                  onSeeAll: () {
                    Get.toNamed(
                      RouteNames.freeExamList,
                      preventDuplicates: true,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ✅ Wrong & Skipped (compact + donut)
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Wrong & Skipped Questions',
                              style: TextStyle(
                                fontSize: Sizes.bodyText(context),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _wrongSkippedModel != null
                                  ? () {
                                Get.toNamed(
                                  RouteNames.wrongSkippedQusDetails,
                                  arguments: _wrongSkippedModel,
                                  preventDuplicates: true,
                                );
                              }
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.primaryColor,
                                side: BorderSide(
                                  color:
                                  AppColor.primaryColor.withOpacity(0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        DashboardWrongSkippedSection(
                          onOpen: (model) {
                            Get.toNamed(
                              RouteNames.wrongSkippedQusDetails,
                              arguments: model,
                              preventDuplicates: true,
                            );
                          },
                          onModelLoaded: _updateWrongSkippedModel,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ NEW: Favourites Section
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saved Favourites',
                              style: TextStyle(
                                fontSize: Sizes.bodyText(context),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Get.toNamed(
                                  RouteNames.favouriteQuestionsList,
                                  preventDuplicates: true,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.primaryColor,
                                side: BorderSide(
                                  color:
                                  AppColor.primaryColor.withOpacity(0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        DashboardFavouritesSection(
                          onOpen: (model) {
                            Get.toNamed(
                              RouteNames.favouriteQuestionsList,
                              arguments: model,
                              preventDuplicates: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // ✅ Tap-able scroll indicator at bottom
        if (_showScrollIndicator)
          Positioned(
            bottom: bottomInset + 16,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _scrollDownOnTap,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColor.whiteColor.withOpacity(0.4),
                        AppColor.whiteColor.withOpacity(0.6),
                      ],
                    ),
                    border: Border.all(
                      color: AppColor.blackColor.withOpacity(0.06),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.blackColor.withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
