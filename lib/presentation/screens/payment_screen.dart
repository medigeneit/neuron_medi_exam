// lib/presentation/screens/payment/payment_screen.dart
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/helpers/payment_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:medi_exam/presentation/widgets/hero_header_with_image.dart';
import 'package:medi_exam/presentation/utils/responsive.dart';
import 'package:medi_exam/data/services/payment_details_service.dart';
import 'package:medi_exam/data/models/payment_details_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Map<String, dynamic> batchData;

  final PaymentDetailsService _paymentDetailsService = PaymentDetailsService();

  PaymentDetailsModel? _paymentDetails;
  bool _loading = true;
  String? _error;

  String? _selectedVendor; // 'bkash' | 'sslcommerz' | 'nagad'
  final GlobalKey<SlideActionState> _slideKey = GlobalKey<SlideActionState>();

  @override
  void initState() {
    super.initState();
    batchData = Get.arguments ?? {};
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    final String admissionId = (batchData['admissionId'] ?? '').toString();
    if (admissionId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Admission ID not found.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final response =
    await _paymentDetailsService.fetchPaymentDetails(admissionId);

    if (!mounted) return;

    if (response.isSuccess) {
      final PaymentDetailsModel model =
      response.responseData is PaymentDetailsModel
          ? response.responseData as PaymentDetailsModel
          : PaymentDetailsModel.fromJson(
        (response.responseData as Map<String, dynamic>? ?? {}),
      );

      // pick first available gateway as default
      final String? firstVendor =
      (model.paymentGateways?.isNotEmpty ?? false)
          ? model.paymentGateways!.first.safeVendor.toLowerCase()
          : null;

      setState(() {
        _paymentDetails = model;
        _selectedVendor = firstVendor;
        _loading = false;
      });
    } else {
      setState(() {
        _error = response.errorMessage ?? 'Failed to load payment details.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];
    final bool isMobile = Responsive.isMobile(context);

    // Model shortcuts
    final admission = _paymentDetails?.admission;
    final gateways = _paymentDetails?.paymentGateways ?? [];

    final double payableAmount = admission?.safePayableAmount ?? 0.0;

    // extra bottom padding so content isn't hidden under the pinned slider
    const double contentBottomPadding = 120;

    return CommonScaffold(
      title: 'Payment',
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Collapsible hero header
              if (_loading)
                SliverToBoxAdapter(
                  child: Container(
                    height: isMobile ? 260 : 340,
                    child: Center(child: LoadingWidget()),
                  ),
                )
              else if (_error == null && _paymentDetails != null)
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  pinned: false,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isMobile ? 260 : 340,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: HeroHeader(
                      banner: admission?.safeBannerUrl ?? '',
                      headerTitle: admission?.safeBatchName ?? 'Batch',
                      headerSubtitle: admission?.safeCoursePackageName ?? 'Discipline/Faculty',
                      time: admission?.safeExamTime ?? '-',
                      days: admission?.safeExamDays ?? '-',
                      startDate: admission?.safeStartDate ?? '-',
                    ),
                  ),
                ),

              // Error state
              if (_error != null && !_loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: ErrorCard(
                      message: _error!,
                      onRetry: _fetchPaymentDetails,
                    ),
                  ),
                ),

              // Content when loaded
              if (!_loading && _error == null) ...[

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: _buildEnrollmentDetails(admission),
                  ),
                ),

                // Modern “details” section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: _buildModernPaymentDetails(admission),
                  ),
                ),

                // Dynamic payment methods
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: _buildPaymentMethods(gateways),
                  ),
                ),

                // spacer at bottom so last card isn't obscured by slider
                const SliverToBoxAdapter(
                    child: SizedBox(height: contentBottomPadding)),
              ],
            ],
          ),

          // Loading overlay
          if (_loading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Center(child: LoadingWidget()),
              ),
            ),

          // Pinned slide-to-pay at bottom
          if (!_loading && _error == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildPayButton(gradientColors, payableAmount),
            ),
        ],
      ),
    );
  }

  // ---------- Modern details section ----------

  Widget _buildModernPaymentDetails(Admission? a) {
    final double coursePrice = a?.safeCoursePrice ?? 0.0;
    final double doctorDiscountAmount = a?.safeDoctorDiscountAmount ?? 0.0;
    final String doctorDiscountTitle =
    (a?.safeDoctorDiscountTitle ?? '').trim().isEmpty
        ? 'Doctor Discount'
        : a!.safeDoctorDiscountTitle;

    final double totalAmount = a?.safeTotalAmount ?? 0.0;
    final double paidAmount = a?.safePaidAmount ?? 0.0;
    final double payableAmount = a?.safePayableAmount ?? 0.0;

    final double progress =
    (totalAmount > 0) ? (paidAmount.clamp(0, totalAmount) / totalAmount) : 0;

    return Stack(
      children: [
        // Gradient glow behind the card
        Positioned.fill(
          top: 10,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.indigo.withOpacity(0.12),
                  AppColor.purple.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColor.indigo.withOpacity(0.12),
                  blurRadius: 36,
                  spreadRadius: 4,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
        ),

        // Glassy card
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.85),
                    Colors.white.withOpacity(0.70),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  // Header row + badge
                  Row(
                    children: [
                      badgeIcon(
                        icon: Icons.receipt_long_rounded,
                        colors: [AppColor.indigo, AppColor.purple],
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Big due now + mini chips
                  LayoutBuilder(
                    builder: (context, c) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              AppColor.indigo.withOpacity(0.08),
                              AppColor.purple.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: AppColor.indigo.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                pill(
                                  text: 'Due Now',
                                  icon: Icons.flash_on_rounded,
                                  fg: Colors.white,
                                  bg: AppColor.purple,
                                ),
                                if (doctorDiscountAmount > 0)
                                  softChip(
                                    icon: Icons.local_offer_rounded,
                                    label: doctorDiscountTitle,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ShaderMask(
                              shaderCallback: (r) => LinearGradient(
                                colors: [AppColor.indigo, AppColor.purple],
                              ).createShader(r),
                              child: Text(
                                '৳${payableAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white, // masked by shader
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Two quick tiles (Course price / Discount)
                  Row(
                    children: [
                      Expanded(
                        child: miniStatTile(
                          title: 'Course Price',
                          value: '৳${coursePrice.toStringAsFixed(2)}',
                          leading: Icons.school_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (doctorDiscountAmount > 0)
                        Expanded(
                          child: miniStatTile(
                            title: doctorDiscountTitle,
                            value: doctorDiscountAmount > 0
                                ? '-৳${doctorDiscountAmount.toStringAsFixed(2)}'
                                : '৳0.00',
                            leading: Icons.local_offer_rounded,
                            isDiscount: doctorDiscountAmount > 0,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  gradientDivider(),

                  if (totalAmount != payableAmount) ...[
                    const SizedBox(height: 16),
                    // Breakdown rows
                    breakdownRow(
                        'Total Amount', '৳${totalAmount.toStringAsFixed(2)}'),
                  ],

                  if (paidAmount > 0) ...[
                    const SizedBox(height: 8),
                    breakdownRow(
                        'Paid Amount', '৳${paidAmount.toStringAsFixed(2)}'),
                  ],
                  const SizedBox(height: 10),
                  breakdownRow(
                    'Payable Amount',
                    '৳${payableAmount.toStringAsFixed(2)}',
                    highlight: true,
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'All charges are shown in BDT.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Enrollment section ----------

  Widget _buildEnrollmentDetails(Admission? a) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              badgeIcon(
                icon: Icons.info_outline_rounded,
                colors: [AppColor.indigo, AppColor.purple],
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Enrollment Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          twoColRow('Registration', a?.safeRegNo ?? '—', context),
          const SizedBox(height: 14),
          twoColRow('Batch', a?.safeBatchName ?? '—', context),
          const SizedBox(height: 8),
          twoColRow('Course', a?.safeCourseName ?? '—', context),
          const SizedBox(height: 8),
          twoColRow('Package', a?.safeCoursePackageName ?? '—', context),
        ],
      ),
    );
  }

  // ---------- Payment methods ----------

  Widget _buildPaymentMethods(List<PaymentGateway> gateways) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              badgeIcon(
                icon: Icons.payment_rounded,
                colors: [AppColor.indigo, AppColor.purple],
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          if (gateways.isEmpty)
            Text(
              'No payment gateway available.',
              style: TextStyle(fontSize: 14.5, color: Colors.grey[700]),
            )
          else
            Column(
              children: gateways.map((g) {
                final value = g.safeVendor.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaymentMethodOptionTile(
                    value: value,
                    imagePath: logoForVendor(g.safeVendor),
                    title:
                    g.hasValidName ? g.safeName : titleForVendor(g.safeVendor),
                    description: subtitleForVendor(g.safeVendor),
                    selected: _selectedVendor?.toLowerCase() ==
                        g.safeVendor.toLowerCase(),
                    onTap: () => setState(() => _selectedVendor = value),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------- Pay button ----------

  Widget _buildPayButton(List<Color> gradientColors, double payableAmount) {
    final bool canPay =
        payableAmount > 0 && (_selectedVendor?.isNotEmpty ?? false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(2), // subtle glossy edge
          child: SlideAction(
            key: _slideKey,
            height: 56,
            elevation: 0,
            borderRadius: 32,
            outerColor: Colors.transparent, // show parent gradient
            innerColor: Colors.white,
            text: 'Slide to Pay ৳${payableAmount.toStringAsFixed(2)}',
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
            sliderRotate: true,
            sliderButtonIcon:
            const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
            submittedIcon: const Icon(Icons.check, color: Colors.white),
            onSubmit: () async {
              if (!canPay) {
                Get.snackbar(
                  'Payment',
                  payableAmount <= 0
                      ? 'No payable amount due.'
                      : 'Please select a payment method.',
                  backgroundColor: Colors.yellow[100],
                  colorText: Colors.black,
                );
                _slideKey.currentState?.reset();
                return;
              }
              _processPayment();
            },
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    final vendor = _selectedVendor?.toLowerCase();
    if (vendor == 'bkash') {
      Get.snackbar(
        'bKash Payment',
        'Redirecting to bKash payment gateway...',
        backgroundColor: Colors.green[100],
        colorText: Colors.black,
      );
    } else if (vendor == 'sslcommerz') {
      Get.snackbar(
        'SSLCommerz Payment',
        'Redirecting to SSLCommerz payment gateway...',
        backgroundColor: Colors.blue[100],
        colorText: Colors.black,
      );
    } else if (vendor == 'nagad') {
      Get.snackbar(
        'Nagad Payment',
        'Redirecting to Nagad payment gateway...',
        backgroundColor: Colors.orange[100],
        colorText: Colors.black,
      );
    } else {
      Get.snackbar(
        'Payment',
        'Unsupported payment method.',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }

    // TODO: Hook your real redirection/initiation here.
    _slideKey.currentState?.reset();
  }
}
