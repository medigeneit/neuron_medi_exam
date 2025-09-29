import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/helpers/payment_screen_helpers.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

import 'package:medi_exam/data/services/manual_payment_service.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/presentation/widgets/payment_success_dialog.dart';

enum ManualChannel { bkash, nagad, rocket }

class ManualPaymentScreen extends StatefulWidget {
  const ManualPaymentScreen({Key? key}) : super(key: key);

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  late final Map<String, dynamic> args;

  // Incoming args
  late final String admissionId;
  late final double amount;
  late final String accountNumber;

  final TextEditingController _txnController = TextEditingController();
  final ManualPaymentService _service = ManualPaymentService();

  ManualChannel _selected = ManualChannel.bkash; // default selection
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    args = Get.arguments ?? {};
    admissionId = (args['admissionId'] ?? '').toString();
    amount = double.tryParse((args['amount'] ?? '0').toString()) ?? 0.0;
    accountNumber = (args['accountNumber'] ?? '').toString();
  }

  @override
  void dispose() {
    _txnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];

    return CommonScaffold(
      title: 'Manual Payment',
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _accountCard(),
              const SizedBox(height: 12),
              _channelCard(),
              const SizedBox(height: 12),
              _txnInputCard(),
            ],
          ),

          // Optional dim overlay while submitting
          if (_submitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),

          // Pinned submit button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _submitButton(gradientColors),
          ),
        ],
      ),
    );
  }



  // ------- account number card -------
  Widget _accountCard() {
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                badgeIcon(
                  icon: Icons.account_balance_wallet_rounded,
                  colors: [AppColor.indigo, AppColor.purple],
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Pay to This Number',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      accountNumber.isNotEmpty ? accountNumber : '— not available —',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy number',
                    onPressed: accountNumber.isEmpty
                        ? null
                        : () async {
                      await Clipboard.setData(ClipboardData(text: accountNumber));
                      Get.snackbar(
                        'Copied',
                        'Number copied to clipboard.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green[50],
                        colorText: Colors.black,
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make a payment with your selected wallet, then submit your Transaction ID below.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // ------- channel selection card -------
  Widget _channelCard() {
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                badgeIcon(icon: Icons.payment_rounded, colors: [AppColor.indigo, AppColor.purple]),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Select Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // PNG logo tiles
            _channelTile(
              title: 'bKash',
              subtitle: 'Fast and secure payment with bKash',
              value: ManualChannel.bkash,
              imagePath: AssetsPath.bkashLogo,
            ),
            const SizedBox(height: 10),
            _channelTile(
              title: 'Nagad',
              subtitle: 'Fast and secure payment with Nagad',
              value: ManualChannel.nagad,
              imagePath: AssetsPath.nagadLogo,
            ),
            const SizedBox(height: 10),
            _channelTile(
              title: 'Rocket',
              subtitle: 'DBBL Rocket mobile banking',
              value: ManualChannel.rocket,
              imagePath: AssetsPath.rocketLogo, // Add to AssetsPath if missing
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelTile({
    required String title,
    required String subtitle,
    required ManualChannel value,
    required String imagePath, // png logo path
  }) {
    final selected = _selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
            // PNG logo (same look as PaymentMethodOptionTile)
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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
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

  // ------- txn input card -------
  Widget _txnInputCard() {
    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: AppColor.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                badgeIcon(icon: Icons.confirmation_number_rounded, colors: [AppColor.indigo, AppColor.purple]),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Transaction ID',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _txnController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter your bKash/Nagad/Rocket Txn ID',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'After submitting, please allow up to 24 hours for verification and payment initiation.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // ------- submit -------
  Widget _submitButton(List<Color> gradientColors) {
    return Opacity(
      opacity: _submitting ? 0.8 : 1,
      child: AbsorbPointer(
        absorbing: _submitting,
        child: Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onSubmit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: _submitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    'Submit Manual Payment (৳${amount.toStringAsFixed(2)})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final txid = _txnController.text.trim();
    if (admissionId.isEmpty) {
      Get.snackbar(
        'Missing Admission',
        'Admission ID is required to submit payment.',
        backgroundColor: Colors.red[50],
        colorText: Colors.black,
      );
      return;
    }
    if (amount <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Amount must be greater than 0.',
        backgroundColor: Colors.red[50],
        colorText: Colors.black,
      );
      return;
    }
    if (txid.isEmpty) {
      Get.snackbar(
        'Transaction ID required',
        'Please enter your ${_labelForChannel(_selected)} Transaction ID.',
        backgroundColor: Colors.yellow[100],
        colorText: Colors.black,
      );
      return;
    }

    final gateway = _gatewayKey(_selected); // 'bkash' | 'nagad' | 'rocket'

    setState(() => _submitting = true);

    final NetworkResponse resp = await _service.submitManualPayment(
      admissionId: admissionId,
      transId: txid,
      amount: amount,
      gatewayType: gateway,
    );

    setState(() => _submitting = false);

    if (resp.isSuccess) {
      final data = (resp.responseData is Map<String, dynamic>)
          ? resp.responseData as Map<String, dynamic>
          : null;

      // build the two strings separately
      final amountText = '৳${(data?['amount'] ?? amount).toString()}';
      final message = 'Payment Submitted\nWe’ll verify it within 24 hours.'; // or any custom message you want

      await PaymentSuccessDialog.show(
        message: message,
        amountText: amountText,
      );
    } else {
      Get.snackbar(
        'Submission Failed',
        resp.errorMessage ?? 'Could not submit your manual payment.',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  String _labelForChannel(ManualChannel ch) {
    switch (ch) {
      case ManualChannel.bkash:
        return 'bKash';
      case ManualChannel.nagad:
        return 'Nagad';
      case ManualChannel.rocket:
        return 'Rocket';
    }
  }

  String _gatewayKey(ManualChannel ch) {
    switch (ch) {
      case ManualChannel.bkash:
        return 'bkash';
      case ManualChannel.nagad:
        return 'nagad';
      case ManualChannel.rocket:
        return 'rocket';
    }
  }

/*
  void _showSuccessDialog(Map<String, dynamic>? data) {
    final txid       = data?['trans_id']?.toString() ?? _txnController.text.trim();
    final amt        = data?['amount']?.toString() ?? amount.toStringAsFixed(2);
    final gatewayRaw = data?['gateway_type']?.toString() ?? _gatewayKey(_selected);
    final gateway    = gatewayRaw.isNotEmpty
        ? gatewayRaw[0].toUpperCase() + gatewayRaw.substring(1)
        : _labelForChannel(_selected);

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.94, end: 1.0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              builder: (context, scale, _) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.92),
                          Colors.white.withOpacity(0.84),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.indigo.withOpacity(0.16),
                          blurRadius: 36,
                          spreadRadius: 4,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated check badge with glow
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutBack,
                          builder: (context, s, _) {
                            return Transform.scale(
                              scale: s,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [AppColor.indigo, AppColor.purple]),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.indigo.withOpacity(0.35),
                                      blurRadius: 22,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Payment Submitted',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),

                        // Big gradient amount with subtle sheen
                        _GradientAmount(amountText: '৳$amt'),

                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _ChipPill(
                              icon: Icons.account_balance_wallet_rounded,
                              label: gateway,
                            ),
                            if (txid.isNotEmpty)
                              _CopyPill(
                                label: 'Txn: $txid',
                                onCopy: () async {
                                  await Clipboard.setData(ClipboardData(text: txid));
                                  Get.snackbar(
                                    'Copied', 'Transaction ID copied.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green[50],
                                    colorText: Colors.black,
                                  );
                                },
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Text(
                          'We’ll verify it within 24 hours.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                        ),

                        const SizedBox(height: 16),
                        gradientDivider(),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _OutlinedBtn(
                                label: 'Close',
                                onTap: () => Get.back(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PrimaryGradBtn(
                                label: 'Go to Dashboard',
                                onTap: () {
                                  Get.back();
                                  Get.offAllNamed(RouteNames.navBar, arguments: 0);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }*/



}

// Big gradient amount with a subtle animated sheen sweep
class _GradientAmount extends StatefulWidget {
  final String amountText;
  const _GradientAmount({required this.amountText});

  @override
  State<_GradientAmount> createState() => _GradientAmountState();
}

class _GradientAmountState extends State<_GradientAmount>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // one-time sweep from left to right
        final t = _c.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            ShaderMask(
              shaderCallback: (r) => LinearGradient(
                colors: [AppColor.indigo, AppColor.purple],
              ).createShader(r),
              child: Text(
                widget.amountText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            // subtle moving sheen
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.25,
                  child: Transform.translate(
                    offset: Offset(-140 + (280 * t), 0),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// small filled chip
class _ChipPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChipPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

// copyable txn pill
class _CopyPill extends StatelessWidget {
  final String label;
  final VoidCallback onCopy;
  const _CopyPill({required this.label, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onCopy,
            child: const Icon(Icons.copy_rounded, size: 14),
          ),
        ],
      ),
    );
  }
}

// primary gradient button
class _PrimaryGradBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryGradBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// outlined button
class _OutlinedBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinedBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




