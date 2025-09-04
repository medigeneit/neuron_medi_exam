import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:slide_to_act/slide_to_act.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Map<String, dynamic> batchData;
  String _selectedPaymentMethod = 'bkash';
  final double _processingFee = 50.0;
  final GlobalKey<SlideActionState> _slideKey = GlobalKey<SlideActionState>();

  @override
  void initState() {
    super.initState();
    batchData = Get.arguments ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];

    // Extracting the required data from the map
    final title = batchData['title'] ?? '';
    final startDate = batchData['startDate'] ?? '';
    final days = batchData['days'] ?? '';
    final time = batchData['time'] ?? '';
    final priceString = batchData['price'] ?? '0';
    final discountString = batchData['discount'] ?? '0';
    final imageUrl = batchData['imageUrl'] ?? '';

    // Parse numeric values from strings
    final double price = _parsePrice(priceString);
    final double discountPercent = _parseDiscount(discountString);

    // Calculate final amount
    final double discountedPrice =
        discountPercent > 0 ? price - (price * discountPercent / 100) : price;
    final double totalAmount = discountedPrice + _processingFee;

    return CommonScaffold(
      title: 'Payment',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Info Card with modern hero banner
            _buildBatchInfoCard(title, startDate, days, time, imageUrl),

            const SizedBox(height: 20),

            // Payment Details
            _buildPaymentDetails(
              price,
              discountPercent,
              _processingFee,
              discountedPrice,
              totalAmount,
            ),

            const SizedBox(height: 20),

            // Payment Methods
            _buildPaymentMethods(),

            const SizedBox(height: 28),

            // Pay Button
            _buildPayButton(gradientColors, totalAmount),
          ],
        ),
      ),
    );
  }

  // Helper method to parse price string (removes '৳', commas, and spaces)
  double _parsePrice(String priceString) {
    try {
      String cleaned = priceString
          .replaceAll('৳', '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  // Helper method to parse discount string (extracts numeric percentage)
  double _parseDiscount(String discountString) {
    try {
      // Remove non-numeric characters except decimal point and percentage
      String cleaned = discountString.replaceAll(RegExp(r'[^0-9.%]'), '');

      if (cleaned.contains('%')) {
        String numberPart = cleaned.split('%').first;
        return double.parse(numberPart);
      }
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildBatchInfoCard(String title, String startDate, String days,
      String time, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner with overlay & soft gradient
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  color: AppColor.purple.withOpacity(0.15)),
                        )
                      : Container(color: AppColor.purple.withOpacity(0.15)),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Title on banner
                Positioned(
                  right: 16,
                  bottom: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          title.isEmpty ? 'Course' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(icon: Icons.date_range, label: startDate),
                      _chip(icon: Icons.calendar_today_rounded, label: days),
                      _chip(icon: Icons.access_time_rounded, label: time),
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

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.indigo),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(double price, double discount,
      double processingFee, double discountedPrice, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.94),
          ],
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(Icons.receipt_long, AppColor.purple),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _buildAmountRow('Course Fee', '৳${price.toStringAsFixed(2)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildAmountRow(
              'Discount (${discount.toStringAsFixed(0)}%)',
              '-৳${(price * discount / 100).toStringAsFixed(2)}',
              isDiscount: true,
            ),
            const SizedBox(height: 8),
            _buildAmountRow(
              'Discounted Price',
              '৳${discountedPrice.toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 8),
          _buildAmountRow(
            'Processing Fee',
            '৳${processingFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.12),
                  Colors.transparent
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildAmountRow(
            'Total Amount',
            '৳${totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14.5,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? Colors.black : Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isTotal
                ? AppColor.indigo.withOpacity(0.08)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isTotal ? AppColor.indigo.withOpacity(0.3) : Colors.black12,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14.5,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
              color: isDiscount
                  ? Colors.green[700]
                  : (isTotal ? AppColor.indigo : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.purple.withOpacity(0.06),
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
            children: [
              _circleIcon(Icons.payment, AppColor.indigo),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // bKash
          _buildPaymentMethodOption(
            'bkash',
            AssetsPath.bkashLogo,
            'Fast and secure payment with bKash',
          ),
          const SizedBox(height: 12),

          // SSLCommerz
          _buildPaymentMethodOption(
            'sslcommerz',
            AssetsPath.sslcommerzLogo,
            'Pay with card, bank account or other methods',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      String value, String imagePath, String description) {
    final bool selected = _selectedPaymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedPaymentMethod = value),
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
            color:
                selected ? AppColor.indigo.withOpacity(0.45) : Colors.black12,
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
                  Text(
                    value == 'bkash' ? 'bKash' : 'SSLCommerz',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
              child: const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(List<Color> gradientColors, double totalAmount) {
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
            // optional
            height: 56,
            elevation: 0,
            borderRadius: 32,
            outerColor: Colors.transparent,
            // show parent gradient
            innerColor: Colors.white,
            text: 'Slide to Pay ৳${totalAmount.toStringAsFixed(2)}',
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
            sliderRotate: true,
            // custom arrow so it's visible even with transparent outerColor
            sliderButtonIcon: const Icon(Icons.arrow_forward_ios,
                color: Colors.black, size: 18),
            submittedIcon: const Icon(Icons.check, color: Colors.white),
            onSubmit: () async {
              _processPayment();
              // No manual reset needed — your SlideAction calls reset() after onSubmit().
            },
          ),
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  void _processPayment() {
    // Handle payment based on selected method (unchanged)
    if (_selectedPaymentMethod == 'bkash') {
      Get.snackbar(
        'bKash Payment',
        'Redirecting to bKash payment gateway...',
        backgroundColor: Colors.green[100],
        colorText: Colors.black,
      );
    } else if (_selectedPaymentMethod == 'sslcommerz') {
      Get.snackbar(
        'SSLCommerz Payment',
        'Redirecting to SSLCommerz payment gateway...',
        backgroundColor: Colors.blue[100],
        colorText: Colors.black,
      );
    }
  }
}
