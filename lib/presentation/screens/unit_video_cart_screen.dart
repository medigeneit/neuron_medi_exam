import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/unit_video_bkash_checkout_model.dart';
import 'package:medi_exam/data/models/unit_video_bkash_payment_status_model.dart';
import 'package:medi_exam/data/models/unit_video_cart_model.dart';
import 'package:medi_exam/data/services/unit_video_cart_service.dart';
import 'package:medi_exam/data/services/unit_video_payment_service.dart';
import 'package:medi_exam/presentation/screens/unit_video_bkash_webview_page.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/payment_success_dialog.dart';
import 'package:slide_to_act/slide_to_act.dart';

class UnitVideoCartScreen extends StatefulWidget {
  const UnitVideoCartScreen({super.key});

  @override
  State<UnitVideoCartScreen> createState() => _UnitVideoCartScreenState();
}

class _UnitVideoCartScreenState extends State<UnitVideoCartScreen> {
  final UnitVideoCartService _cartService = UnitVideoCartService();
  final UnitVideoPaymentService _paymentService = UnitVideoPaymentService();

  final GlobalKey<SlideActionState> _slideKey = GlobalKey<SlideActionState>();

  bool _isLoading = true;
  bool _isRemovingSingle = false;
  bool _isClearingAll = false;
  bool _isCheckingOut = false;

  int? _removingCartItemId;

  UnitVideoCartModel _cart = const UnitVideoCartModel();

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await _cartService.fetchUnitVideoCart();

      if (response.isSuccess && response.responseData is UnitVideoCartModel) {
        setState(() {
          _cart = response.responseData as UnitVideoCartModel;
        });
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch cart',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while fetching cart: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeSingleItem(UnitVideoCartItemModel item) async {
    final cartItemId = item.cartItemId;

    if (cartItemId == null) {
      Get.snackbar(
        'Error',
        'Cart item id not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final shouldRemove = await _showConfirmDialog(
      title: 'Remove Video',
      message: 'Do you want to remove this video from cart?',
      confirmText: 'Remove',
    );

    if (shouldRemove != true) return;

    setState(() {
      _isRemovingSingle = true;
      _removingCartItemId = cartItemId;
    });

    try {
      final response = await _cartService.removeSingleVideoFromCart(
        cartItemId.toString(),
      );

      if (response.isSuccess && response.responseData is UnitVideoCartModel) {
        setState(() {
          _cart = response.responseData as UnitVideoCartModel;
        });

        Get.snackbar(
          'Success',
          'Cart item removed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to remove cart item',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while removing item: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRemovingSingle = false;
          _removingCartItemId = null;
        });
      }
    }
  }

  Future<void> _clearAllCart() async {
    if (_cart.isEmpty) return;

    final shouldClear = await _showConfirmDialog(
      title: 'Clear Cart',
      message: 'Do you want to remove all videos from cart?',
      confirmText: 'Clear All',
    );

    if (shouldClear != true) return;

    setState(() => _isClearingAll = true);

    try {
      final response = await _cartService.clearUnitVideoCart();

      if (response.isSuccess && response.responseData is UnitVideoCartModel) {
        setState(() {
          _cart = response.responseData as UnitVideoCartModel;
        });

        Get.snackbar(
          'Success',
          'Cart cleared successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to clear cart',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while clearing cart: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isClearingAll = false);
      }
    }
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      Get.snackbar(
        'Checkout',
        'Your cart is empty.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      _slideKey.currentState?.reset();
      return;
    }

    if (_isCheckingOut) return;

    setState(() => _isCheckingOut = true);

    try {
      final response = await _paymentService.initiateBkashCheckout();

      if (!mounted) return;

      if (!response.isSuccess || response.responseData == null) {
        Get.snackbar(
          'bKash Payment',
          response.errorMessage ?? 'Failed to initialize payment.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final checkoutModel = response.responseData is UnitVideoBkashCheckoutModel
          ? response.responseData as UnitVideoBkashCheckoutModel
          : UnitVideoBkashCheckoutModel.parse(response.responseData);

      if (checkoutModel.success != true) {
        Get.snackbar(
          'bKash Payment',
          checkoutModel.message ?? 'Failed to initialize payment.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final paymentUrl = checkoutModel.paymentUrl.trim();

      // Important: this must be bkash_payment_id, not payment_id.
      final paymentID = checkoutModel.bkashPaymentId.trim();

      if (paymentUrl.isEmpty || paymentID.isEmpty) {
        Get.snackbar(
          'bKash Payment',
          'Payment URL or bKash payment ID is missing.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final result = await Navigator.of(context)
          .push<UnitVideoBkashPaymentStatusModel>(
        MaterialPageRoute(
          builder: (_) => UnitVideoBkashWebViewPage(
            initialUrl: paymentUrl,
            paymentID: paymentID,
          ),
        ),
      );

      if (!mounted) return;

      if (result == null) {
        Get.snackbar(
          'bKash Payment',
          'Payment was cancelled.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (result.isSuccess) {
        _slideKey.currentState?.reset();

        if (mounted) {
          setState(() => _isCheckingOut = false);
        }

        await PaymentSuccessDialog.show(
          message: result.statusMessage.isNotEmpty
              ? result.statusMessage
              : 'Payment successful.',
          amountText:
          '৳${checkoutModel.data?.totalAmount ?? _cart.totalAmount ?? 0}',
        );

        if (!mounted) return;

        // Pop the cart screen after showing success dialog.
        Navigator.of(context).pop(true);
        return;
      } else {
        await _showPaymentFailedDialog(
          result.statusMessage.isNotEmpty
              ? result.statusMessage
              : 'Payment was not completed.',
        );

        await _fetchCart();
      }
    } catch (e) {
      Get.snackbar(
        'bKash Payment',
        'An error occurred during checkout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _slideKey.currentState?.reset();

      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  Future<void> _showPaymentFailedDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(
          message.isEmpty ? 'Your payment was not completed.' : message,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColor.primaryTextColor,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Video Cart',
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : RefreshIndicator(
        onRefresh: _fetchCart,
        child: _cart.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColor.primaryColor.withOpacity(0.75),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Added unit videos will appear here.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            itemCount: _cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _cart.items[index];
              return _buildCartItemCard(item, index);
            },
          ),
        ),
        _buildBottomSummary(),
      ],
    );
  }

  Widget _buildCartItemCard(UnitVideoCartItemModel item, int index) {
    final bool isRemoving =
        _isRemovingSingle && _removingCartItemId == item.cartItemId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoNumber(index),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCartItemInfo(item),
            ),
            const SizedBox(width: 8),
            isRemoving
                ? const SizedBox(
              width: 36,
              height: 36,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              tooltip: 'Remove',
              onPressed: () => _removeSingleItem(item),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoNumber(int index) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.20),
        ),
      ),
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColor.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCartItemInfo(UnitVideoCartItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.questionTitle ?? 'Unit Video',
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
            color: AppColor.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildInfoChip(
              icon: Icons.video_library_outlined,
              text: 'Video ID: ${item.questionVideoLinkId ?? '-'}',
            ),
            _buildInfoChip(
              icon: Icons.check_circle_outline_rounded,
              text: item.isAvailable == true ? 'Available' : 'Unavailable',
              color: item.isAvailable == true ? Colors.green : Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.payments_outlined,
              size: 18,
              color: AppColor.primaryColor,
            ),
            const SizedBox(width: 5),
            Text(
              '৳${item.amount ?? 0}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final chipColor = color ?? AppColor.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: chipColor.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    final totalAmount = _cart.totalAmount ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColor.primaryColor.withOpacity(0.12),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              title: 'Total Items',
              value: '${_cart.totalItems ?? _cart.items.length}',
            ),
            const SizedBox(height: 6),
            _buildSummaryRow(
              title: 'Total Amount',
              value: '৳$totalAmount',
              isAmount: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                    _isClearingAll || _isCheckingOut ? null : _clearAllCart,
                    icon: _isClearingAll
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.delete_sweep_outlined),
                    label: Text(_isClearingAll ? 'Clearing...' : 'Clear All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCheckoutSlider(totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSlider(int totalAmount) {
    final bool canCheckout =
        !_isCheckingOut && !_isClearingAll && _cart.isNotEmpty && totalAmount > 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: canCheckout
              ? [AppColor.indigo, AppColor.purple]
              : [Colors.grey.shade500, Colors.grey.shade400],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.indigo.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: SlideAction(
            key: _slideKey,
            height: 56,
            elevation: 0,
            borderRadius: 32,
            outerColor: Colors.transparent,
            innerColor: Colors.white,
            text: _isCheckingOut
                ? 'Preparing bKash payment...'
                : 'Swipe to checkout ৳$totalAmount',
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
            sliderRotate: true,
            sliderButtonIcon: _isCheckingOut
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
              size: 18,
            ),
            submittedIcon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
            onSubmit: () async {
              if (!canCheckout) {
                Get.snackbar(
                  'Checkout',
                  totalAmount <= 0
                      ? 'Invalid payable amount.'
                      : 'Checkout is not available right now.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                _slideKey.currentState?.reset();
                return;
              }

              await _checkout();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String value,
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isAmount ? AppColor.primaryColor : AppColor.primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: isAmount ? 17 : 14,
          ),
        ),
      ],
    );
  }
}