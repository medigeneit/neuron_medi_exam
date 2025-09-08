import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/batch_details_model.dart';
import 'package:medi_exam/data/services/batch_details_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/widgets/banner_card_helpers.dart';
import 'package:medi_exam/presentation/widgets/batch_details_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

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
        _errorMessage = response.errorMessage ?? 'Failed to load batch details';
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

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];

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
            // ------------------ CHANGED: Scroll view with collapsible hero ------------------
            CustomScrollView(
              slivers: [
                // Collapsible/minimizable hero image
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  // keep CommonScaffold appbar only
                  toolbarHeight: 0,
                  // no second toolbar
                  collapsedHeight: 0,
                  pinned: false,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 240,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Keep your existing BannerImage
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: BannerImage(url: imageUrl),
                        ),
                        // same soft drop shadow effect as before
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

                // Rest of your previous content (unchanged)
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
                          childAspectRatio: 3.5,
                          children: [
                            BatchInfoPill(
                              icon: Icons.calendar_today_rounded,
                              label: 'Start: $startDate',
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

                        // Offers (unchanged)
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

                        // Expandable HTML (unchanged)
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
                            htmlContent: _batchDetails!.safeRegistrationProcess,
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

          // CTA (unchanged)
          if (!_isLoading && _errorMessage.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      final paymentData = {
                        'batchId': batchId,
                        'coursePackageId': coursePackageId,
                        'title': title,
                        'subTitle': subTitle,
                        'imageUrl': imageUrl,
                        'time': time,
                        'days': days,
                        'startDate': startDate,
                        'coursePrice': _batchDetails?.coursePrice,
                        'newDoctorDiscount': _batchDetails?.newDoctorDiscount,
                        'oldDoctorDiscount': _batchDetails?.oldDoctorDiscount,
                      };
                      Get.toNamed(RouteNames.makePayment,
                          arguments: paymentData);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Enroll Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


