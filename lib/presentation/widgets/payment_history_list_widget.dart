import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/fancy_card_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

class PaymentHistoryListWidget extends StatelessWidget {
  final String batchName;
  final String admissionRegNo;
  final String paidAmount;
  final String invoiceNumber;
  final String invoiceDateHuman;
  final String paymentGateway;
  final bool isPrinting;           // <- new
  final VoidCallback? onDetails;   // <- nullable to allow disabling

  const PaymentHistoryListWidget({
    super.key,
    required this.batchName,
    required this.admissionRegNo,
    required this.paidAmount,
    required this.invoiceNumber,
    required this.invoiceDateHuman,
    required this.paymentGateway,
    required this.onDetails,
    this.isPrinting = false,
  });

  @override
  Widget build(BuildContext context) {
    // Disable card tap while printing
    final canTap = !isPrinting && onDetails != null;

    return FancyBackground(
      gradient: AppColor.deepPrimaryDeepPurpleGradient,
      child: InkWell(
        onTap: canTap ? onDetails : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Batch name + action
                  Row(
                    children: [
                      // Left icon circle
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.whiteColor.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: AppColor.whiteColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          batchName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Sizes.normalText(context),
                            fontWeight: FontWeight.w800,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Print button with loading state
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canTap ? onDetails : null,
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isPrinting
                                  ? AppColor.primaryColor.withOpacity(0.7)
                                  : AppColor.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  AppColor.blackColor.withOpacity(0.5),
                                  blurRadius: 2,
                                  offset: const Offset(1, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: isPrinting
                                  ? SizedBox(
                                key: const ValueKey('spinner'),
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    AppColor.whiteColor,
                                  ),
                                ),
                              )
                                  : Icon(
                                key: const ValueKey('icon'),
                                Icons.print,
                                size: 16,
                                color: AppColor.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        context,
                        icon: Icons.tag_outlined,
                        label: 'Inv: $invoiceNumber',
                      ),
                      _chip(
                        context,
                        icon: Icons.event_outlined,
                        label: 'Date: $invoiceDateHuman',
                      ),
                      _chip(
                        context,
                        icon: Icons.payments_rounded,
                        label: 'Paid: $paidAmount by $paymentGateway',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required IconData icon, required String label}) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade300),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: Sizes.verySmallText(context),
                color: AppColor.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
