import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/batch_details_model.dart';
import 'package:medi_exam/data/services/batch_details_service.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/data/utils/payment_navigator.dart';
import 'package:medi_exam/presentation/utils/responsive.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/animated_gradient_button.dart';
import 'package:medi_exam/presentation/widgets/date_formatter_widget.dart';
import 'package:medi_exam/presentation/widgets/free_exam_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/banner_card_helpers.dart';
import 'package:medi_exam/presentation/widgets/helpers/batch_details_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

// ------------------------- Batch Details Screen -------------------------
class BatchDetailsScreen extends StatefulWidget {
  const BatchDetailsScreen({Key? key}) : super(key: key);

  @override
  _BatchDetailsScreenState createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  final BatchDetailsService _batchDetailsService = BatchDetailsService();
  BatchDetailsModel? _batchDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  late String batchId;
  late String coursePackageId;
  late String imageUrl;
  late String time;
  late String days;
  late String startDate;
  late String title;
  late String subTitle;

  @override
  void initState() {
    super.initState();
    _extractArguments();
    _fetchBatchDetails();
  }

  void _extractArguments() {
    final arguments = Get.arguments ?? {};
    batchId = arguments['batchId'] ?? '';
    coursePackageId = arguments['coursePackageId'] ?? '';
    imageUrl = arguments['imageUrl'] ?? '';
    time = arguments['time'] ?? '';
    days = arguments['days'] ?? '';
    startDate = arguments['startDate'] ?? '';
    title = arguments['title'] ?? '';
    subTitle = arguments['subTitle'] ?? '';
  }

  Future<void> _fetchBatchDetails() async {
    if (batchId.isEmpty || coursePackageId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Missing required parameters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response =
    await _batchDetailsService.fetchBatchDetails(batchId, coursePackageId);

    if (response.isSuccess && response.responseData is BatchDetailsModel) {
      setState(() {
        _batchDetails = response.responseData as BatchDetailsModel;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            response.errorMessage ?? 'Failed to load batch details';
      });
    }
  }

  // --- Helpers for offers ---
  double? _tryParsePrice(dynamic p) {
    if (p == null) return null;
    if (p is num) return p.toDouble();
    final s = p.toString().replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(s);
  }

  // ---------------- NEW: Free Exam handler (auth + navigation) ----------------
  Future<void> _onFreeExamPressed() async {
    final authed = await AuthChecker.to.isAuthenticated();

    Future<void> goNow() async {
      final String courseId =
          _batchDetails?.courseId?.toString() ?? '';
      if (courseId.isEmpty) {
        Get.snackbar(
          'Unavailable',
          'Free exam is not available for this batch yet.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      Get.toNamed(
        RouteNames.freeExams,
        arguments: {
          'url': Urls.freeExamListCourseWise(courseId),
        },
        preventDuplicates: true,
      );
    }

    if (!authed) {
      Get.snackbar('Login Required',
          'Please log in to try the free exam',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));

      final result = await Get.toNamed(
        RouteNames.login,
        arguments: {
          'popOnSuccess': true,
          'returnRoute': null,
          'returnArguments': null,
          'message':
          "You’re one step away! Log in to take the Free Exam.",
        },
      );

      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 300));
        final isNowAuthenticated = await AuthChecker.to.isAuthenticated();
        if (isNowAuthenticated) {
          await goNow();
        }
      }
      return;
    }

    await goNow();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final gradientColors = [AppColor.indigo, AppColor.purple];
    final gradientButtonColors = [Colors.purple, Colors.blue];

    return CommonScaffold(
      title: 'Batch Details',
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: LoadingWidget())
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchBatchDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
          // ------------------ Scroll view with collapsible hero ------------------
            CustomScrollView(
              slivers: [
                // Collapsible/minimizable hero image
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  pinned: false,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isMobile ? 260 : 420,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: BannerImage(url: imageUrl),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Rest of content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    // keep bottom space for CTA
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & SubTitle
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info chips
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: isMobile ? 3.5 : 5.5,
                          children: [
                            BatchInfoPill(
                              icon: Icons.calendar_today_rounded,
                              label: 'Start: ${formatDateStr(startDate)}',
                              bg: const Color(0xFFF0F7FF),
                              iconColor: gradientColors[0],
                            ),
                            BatchInfoPill(
                              icon: Icons.event_repeat_rounded,
                              label: 'Days: $days',
                              bg: const Color(0xFFF0F7FF),
                              iconColor: gradientColors[0],
                            ),
                            BatchInfoPill(
                              icon: Icons.schedule_rounded,
                              label: 'Time: $time',
                              bg: const Color(0xFFF0F7FF),
                              iconColor: gradientColors[0],
                            ),
                            if (_batchDetails?.coursePrice != null)
                              BatchInfoPill(
                                icon: Icons.attach_money_rounded,
                                label: 'Price: ${_batchDetails!.coursePrice}',
                                bg: const Color(0xFFF8FBFF),
                                iconColor: gradientColors[0],
                              ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ---------------- NEW: Free Exam Button (above Schedule) ----------------
                        FreeExamCardButton(
                          onTap: _onFreeExamPressed,
                        ),

                        const SizedBox(height: 12),

                        // Schedule Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: AppColor.blueGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Get.toNamed(
                                  RouteNames.batchSchedule,
                                  arguments: {
                                    'batchPackageId': _batchDetails
                                        ?.batchPackageId
                                        ?.toString() ??
                                        '',
                                    'coursePackageId': _batchDetails
                                        ?.coursePackageId
                                        ?.toString() ??
                                        '',
                                    'batchId': batchId,
                                    'title': title, // batch title
                                    'subTitle': _batchDetails
                                        ?.coursePackageName ??
                                        '', // course_package_name
                                    'startDate': startDate,
                                    'imageUrl': imageUrl,
                                    'time': time ?? '',
                                    'days': days ?? '',
                                  },
                                );
                                print(
                                    'batchPackageID: ${_batchDetails?.batchPackageId}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      color: Colors.white,
                                      size: Sizes.smallIcon(context),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'View Full Schedule',
                                      style: TextStyle(
                                        fontSize: Sizes.normalText(context),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Offers
                        if ((_batchDetails?.newDoctorDiscount ?? 0) > 0 ||
                            (_batchDetails?.oldDoctorDiscount ?? 0) > 0)
                          OfferSection(
                            basePrice:
                            _tryParsePrice(_batchDetails?.coursePrice),
                            newDoctorDiscount:
                            _batchDetails?.newDoctorDiscount, // taka amount
                            oldDoctorDiscount:
                            _batchDetails?.oldDoctorDiscount, // taka amount
                            gradientColors: gradientColors,
                          ),

                        const SizedBox(height: 24),

                        // Expandable HTML sections
                        if (_batchDetails?.hasDescription ?? false)
                          ExpandableHtmlSection(
                            title: 'Batch Details',
                            htmlContent: _batchDetails!.safeDescription,
                            gradientColors: gradientColors,
                          ),

                        if (_batchDetails?.hasDescription ?? false)
                          const SizedBox(height: 16),

                        if (_batchDetails?.hasCourseOutline ?? false)
                          ExpandableHtmlSection(
                            title: 'Course Outline',
                            htmlContent: _batchDetails!.safeCourseOutline,
                            gradientColors: gradientColors,
                          ),

                        if (_batchDetails?.hasCourseOutline ?? false)
                          const SizedBox(height: 16),

                        if (_batchDetails?.hasCourseFeeOffer ?? false)
                          ExpandableHtmlSection(
                            title: 'Course Fee Offer',
                            htmlContent: _batchDetails!.safeCourseFeeOffer,
                            gradientColors: gradientColors,
                          ),

                        if (_batchDetails?.hasCourseFeeOffer ?? false)
                          const SizedBox(height: 16),

                        if (_batchDetails?.hasRegistrationProcess ?? false)
                          ExpandableHtmlSection(
                            title: 'Registration Process',
                            htmlContent:
                            _batchDetails!.safeRegistrationProcess,
                            gradientColors: gradientColors,
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          // --------------------------------------------------------------------

          // Bottom CTA (unchanged)
          if (!_isLoading && _errorMessage.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GradientCTA(
                colors: gradientButtonColors,
                onTap: () {
                  onEnrollPressed(
                    batchId: batchId,
                    coursePackageId: coursePackageId,
                    batchPackageId:
                    _batchDetails?.batchPackageId?.toString() ?? '',
                    title: title,
                    subTitle: subTitle,
                    imageUrl: imageUrl,
                    time: time,
                    days: days,
                    startDate: startDate,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


