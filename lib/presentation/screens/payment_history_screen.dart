import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/payment_history_model.dart';
import 'package:medi_exam/data/services/payment_history_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/payment_history_list_widget.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _service = PaymentHistoryService();

  bool _isLoading = true;
  String _errorMessage = '';
  bool _isPrinting = false;
  String? _printingAdmissionId; // <- track which item is printing
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

  Future<void> _printInvoice(PaymentHistoryItem item) async {
    if (_isPrinting) return;

    // Resolve & validate admissionId first, so we don't get stuck in loading
    final admissionIdRaw = item.admissionId;
    final admissionId = (admissionIdRaw == null) ? '' : admissionIdRaw.toString();
    if (admissionId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing admission ID for invoice')),
        );
      }
      return;
    }

    setState(() {
      _isPrinting = true;
      _printingAdmissionId = admissionId;
    });

    try {
      final url = Urls.invoice(admissionId);

      // Add headers if your endpoint requires auth
      // final headers = {'Authorization': 'Bearer $token'};
      final resp = await http.get(Uri.parse(url) /*, headers: headers*/);

      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }

      final html = resp.body;

      await Printing.layoutPdf(
        name: 'Invoice-$admissionId.pdf',
        onLayout: (format) async => await Printing.convertHtml(
          format: format,
          html: html,
          baseUrl: url,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
          _printingAdmissionId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // Error state
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

                          // Determine if THIS row is printing
                          final currentId = item.admissionId?.toString();
                          final rowIsPrinting = _isPrinting &&
                              currentId != null &&
                              currentId == _printingAdmissionId;

                          return PaymentHistoryListWidget(
                            batchName: _safe(item.batchName),
                            admissionRegNo: _safe(item.admissionRegNo),
                            paidAmount: _safeMoney(item.paidAmount),
                            invoiceNumber: _safe(item.invoiceNumber),
                            invoiceDateHuman: _safe(item.invoiceDateHuman),
                            paymentGateway: _safe(item.transactionGateways),
                            isPrinting: rowIsPrinting,
                            onDetails: _isPrinting
                                ? null // block others while printing
                                : () => _printInvoice(item),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Global loading overlay for first fetch
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
