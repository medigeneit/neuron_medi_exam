// lib/presentation/widgets/payment_screen_helpers.dart
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

/// --------------------
/// Public reusable bits
/// --------------------

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCard({required this.message, required this.onRetry, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColor.indigo.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Failed to load',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Something went wrong', style: const TextStyle(fontSize: 14.5)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodOptionTile extends StatelessWidget {
  final String value;
  final String imagePath;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const PaymentMethodOptionTile({
    Key? key,
    required this.value,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? LinearGradient(
            colors: [
              AppColor.indigo.withOpacity(0.08),
              AppColor.purple.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: selected ? null : Colors.grey[50],
          border: Border.all(
            color: selected ? AppColor.indigo.withOpacity(0.45) : Colors.black12,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColor.indigo.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.contain,
                ),
                color: Colors.white,
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[700],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColor.indigo : Colors.black26,
                  width: 2,
                ),
                color: selected ? AppColor.indigo : Colors.transparent,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// --------------------
/// Generic UI helpers
/// --------------------

BoxDecoration cardDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    gradient: LinearGradient(
      colors: [Colors.white, Colors.white.withOpacity(0.95)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColor.indigo.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 12),
      ),
    ],
    border: Border.all(color: Colors.black.withOpacity(0.05)),
  );
}

Widget twoColRow(String label, String value, BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: Text(
          label,
          style:  TextStyle(
            fontSize: Sizes.normalText(context),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Expanded(
            child: Text(
              value,
              style:  TextStyle(
                fontSize: Sizes.normalText(context),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget gradientDivider() {
  return Container(
    height: 1.2,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.18),
          Colors.transparent,
        ],
      ),
    ),
  );
}

Widget miniStatTile({
  required String title,
  required String value,
  required IconData leading,
  bool isDiscount = false,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      border: Border.all(color: Colors.black12),
    ),
    child: Row(
      children: [
        softIcon(leading),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: isDiscount ? Colors.green[700] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget progressBar(double progress) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 10,
              width: c.maxWidth * progress.clamp(0, 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.indigo, AppColor.purple],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget breakdownRow(String label, String value, {bool highlight = false}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 15.5 : 14.5,
            fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: highlight ? AppColor.indigo.withOpacity(0.08) : Colors.grey.shade50,
          border: Border.all(
            color: highlight ? AppColor.indigo.withOpacity(0.30) : Colors.black12,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 16 : 14.5,
            fontWeight: highlight ? FontWeight.w900 : FontWeight.w800,
            color: highlight ? AppColor.indigo : Colors.black87,
          ),
        ),
      ),
    ],
  );
}

Widget softIcon(IconData icon) {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey.shade100,
      border: Border.all(color: Colors.black12),
    ),
    child: Icon(icon, size: 18, color: Colors.black87),
  );
}

Widget pill({
  required String text,
  required IconData icon,
  required Color fg,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(
          color: bg.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

Widget softChip({required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.black12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black87),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

Widget badgeIcon({required IconData icon, required List<Color> colors}) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: colors),
      boxShadow: [
        BoxShadow(
          color: colors.first.withOpacity(0.30),
          blurRadius: 16,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: const Center(
      // base child, then overlay actual icon with extension
      child: Icon(Icons.check_rounded, color: Colors.white, size: 0),
    ),
  ).stackedWithCenterIcon(icon);
}

/// -------------
/// Vendor utils
/// -------------

String logoForVendor(String vendor) {
  final v = vendor.toLowerCase();
  if (v == 'bkash') return AssetsPath.bkashLogo;
  if (v == 'sslcommerz') return AssetsPath.sslcommerzLogo;
  if (v == 'nagad') return AssetsPath.nagadLogo;
  if (v == 'manual-payment') { return AssetsPath.manualPayment;
  }
  return AssetsPath.sslcommerzLogo;
}

String titleForVendor(String vendor) {
  final v = vendor.toLowerCase();
  if (v == 'bkash') return 'bKash';
  if (v == 'sslcommerz') return 'SSLCommerz';
  if (v == 'nagad') return 'Nagad';
  if (v == 'manual-payment') return 'Manual Payment';
  return vendor;
}

String subtitleForVendor(String vendor) {
  final v = vendor.toLowerCase();
  if (v == 'bkash') return 'Fast and secure payment with bKash';
  if (v == 'sslcommerz') return 'Pay with card, bank account or others';
  if (v == 'nagad') return 'Fast and secure payment with Nagad';
  if (v == 'manual-payment') return 'Pay via bKash/Nagad, then submit Txn ID';
  return 'Secure online payment';
}

/// Tiny extension to overlay an icon on the gradient badge
extension IconStack on Widget {
  Widget stackedWithCenterIcon(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        this,
        Icon(icon, color: Colors.white, size: 18),
      ],
    );
  }
}
