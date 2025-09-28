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
  final VoidCallback onDetails;

  const PaymentHistoryListWidget({
    super.key,
    required this.batchName,
    required this.admissionRegNo,
    required this.paidAmount,
    required this.invoiceNumber,
    required this.invoiceDateHuman,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return FancyBackground(
      gradient: AppColor.deepPurpleCyanGradient,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
        color: AppColor.whiteColor.withOpacity(0.3)
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppColor.whiteColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Batch name
                Text(
                  batchName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.normalText(context),
                    fontWeight: FontWeight.w800,
                    color: AppColor.whiteColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Two rows of subtle glass chips (admission + invoice)
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
                      label: 'Paid: $paidAmount',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Details arrow
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDetails,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColor.deepPurpleCyanGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.indigo.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {required IconData icon, required String label}) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColor.secondaryTextColor),
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

