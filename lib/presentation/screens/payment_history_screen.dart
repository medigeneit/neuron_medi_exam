import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/payment_history_model.dart';
import 'package:medi_exam/data/services/payment_history_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/payment_history_list_widget.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _service = PaymentHistoryService();

  bool _isLoading = true;
  String _errorMessage = '';
  List<PaymentHistoryItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final res = await _service.fetchPaymentHistory();
    if (!mounted) return;

    if (res.isSuccess && res.responseData is PaymentHistoryModel) {
      final model = res.responseData as PaymentHistoryModel;
      setState(() {
        _items = model.items ?? const [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res.errorMessage ?? 'Failed to load payment history';
      });
    }
  }

  String _safe(String? v, {String dash = '—'}) {
    final s = v?.trim();
    return (s == null || s.isEmpty) ? dash : s;
  }

  String _safeMoney(num? n) {
    if (n == null) return '—';
    return n.toString();
  }

  // details dialog (compact, matches your modal style)
  void _showDetails(PaymentHistoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: Sizes.subTitleText(context),
                            fontWeight: FontWeight.w800,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _kv('Batch', _safe(item.batchName)),
                    _kv('Admission Reg. No', _safe(item.admissionRegNo)),
                    _kv('Course', _safe(item.courseName)),
                    _kv('Session', _safe(item.sessionName)),
                    _kv('Invoice No', _safe(item.invoiceNumber)),
                    _kv('Invoice Date', _safe(item.invoiceDateHuman)),
                    _kv('Payment Status', _safe(item.paymentStatus)),
                    _kv('Currency', _safe(item.currency)),
                    const Divider(height: 24),

                    _kv('Course Price', _safeMoney(item.coursePrice)),
                    _kv('Discount Title', _safe(item.discountTitle)),
                    _kv('Discount Amount', _safeMoney(item.discountAmount)),
                    _kv('Total Payable', _safeMoney(item.totalPayable)),
                    _kv('Paid Amount', _safeMoney(item.paidAmount)),
                    _kv('Due Amount', _safeMoney(item.dueAmount)),
                    const Divider(height: 24),

                    _kv('Gateway(s)', _safe(item.transactionGateways)),
                    _kv('Transaction IDs', _safe(item.transactionIds)),
                    _kv('Transactions', item.transactionCount?.toString() ?? '—'),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: Sizes.smallText(context),
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Sizes.bodyText(context),
                color: AppColor.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build inside CommonScaffold just like PaymentScreen
    return CommonScaffold(
      title: 'Payment History',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetch,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment History',
                              style: TextStyle(
                                fontSize: Sizes.bodyText(context),
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your completed and recent payments',
                              style: TextStyle(
                                fontSize: Sizes.smallText(context),
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_items.length}',
                          style: TextStyle(
                            fontSize: Sizes.smallText(context),
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Error state (kept inside the list so pull-to-refresh still works)
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetch,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                // Empty state
                else if (_items.isEmpty)
                  _emptyView(context)
                // List
                else
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final item = _items[i];
                          return PaymentHistoryListWidget(
                            batchName: _safe(item.batchName),
                            admissionRegNo: _safe(item.admissionRegNo),
                            paidAmount: _safeMoney(item.paidAmount),
                            invoiceNumber: _safe(item.invoiceNumber),
                            invoiceDateHuman: _safe(item.invoiceDateHuman),
                            onDetails: () => _showDetails(item),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Loading overlay (keeps the app bar visible)
          if (_isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Center(child: LoadingWidget()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No payments found',
            style: TextStyle(
              fontSize: Sizes.bodyText(context),
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your payment history will appear here',
            style: TextStyle(
              fontSize: Sizes.smallText(context),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
