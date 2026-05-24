import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/unit_video_bkash_payment_status_model.dart';
import 'package:medi_exam/data/services/unit_video_payment_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

class UnitVideoBkashWebViewPage extends StatefulWidget {
  final String initialUrl;
  final String paymentID;

  const UnitVideoBkashWebViewPage({
    super.key,
    required this.initialUrl,
    required this.paymentID,
  });

  @override
  State<UnitVideoBkashWebViewPage> createState() =>
      _UnitVideoBkashWebViewPageState();
}

class _UnitVideoBkashWebViewPageState extends State<UnitVideoBkashWebViewPage> {
  final UnitVideoPaymentService _service = UnitVideoPaymentService();

  InAppWebViewController? _controller;

  bool _isLoading = true;
  bool _isCheckingStatus = false;
  bool _hasReturnedResult = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(false);
    }
  }

  bool _looksLikeCallbackUrl(String url) {
    final lower = url.toLowerCase();

    return lower.contains('unit-video-payments/bkash/callback') ||
        lower.contains('/bkash/callback') ||
        lower.contains('paymentid=') && lower.contains('callback');
  }

  Future<void> _checkStatusAndReturn() async {
    if (_isCheckingStatus || _hasReturnedResult) return;

    final paymentID = widget.paymentID.trim();

    if (paymentID.isEmpty) {
      Get.snackbar(
        'bKash Payment',
        'Payment ID not found.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isCheckingStatus = true);

    try {
      final response = await _service.checkBkashPaymentStatus(paymentID);

      if (!mounted) return;

      UnitVideoBkashPaymentStatusModel model;

      if (response.responseData is UnitVideoBkashPaymentStatusModel) {
        model = response.responseData as UnitVideoBkashPaymentStatusModel;
      } else {
        model = UnitVideoBkashPaymentStatusModel.parse(response.responseData);
      }

      _hasReturnedResult = true;

      Navigator.of(context).pop(model);
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'bKash Payment',
        'Failed to check payment status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted && !_hasReturnedResult) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  Future<bool> _handleBack() async {
    final canGoBack = await _controller?.canGoBack() ?? false;

    if (canGoBack) {
      await _controller?.goBack();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'bKash Payment',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.initialUrl),
              ),
              initialSettings: InAppWebViewSettings(
                useHybridComposition: false,
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                supportMultipleWindows: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useShouldOverrideUrlLoading: true,
                transparentBackground: false,
                disableDefaultErrorPage: true,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onLoadStart: (controller, url) async {
                if (mounted) setState(() => _isLoading = true);

                final value = url?.toString() ?? '';
                if (value.isNotEmpty && _looksLikeCallbackUrl(value)) {
                  await _checkStatusAndReturn();
                }
              },
              onUpdateVisitedHistory: (controller, url, isReload) async {
                final value = url?.toString() ?? '';

                if (value.isNotEmpty && _looksLikeCallbackUrl(value)) {
                  await _checkStatusAndReturn();
                }
              },
              onLoadStop: (controller, url) async {
                if (mounted) setState(() => _isLoading = false);

                final value = url?.toString() ?? '';
                if (value.isNotEmpty && _looksLikeCallbackUrl(value)) {
                  await _checkStatusAndReturn();
                }
              },
              shouldOverrideUrlLoading: (controller, action) async {
                final url = action.request.url?.toString() ?? '';

                if (url.isNotEmpty && _looksLikeCallbackUrl(url)) {
                  await _checkStatusAndReturn();
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onCreateWindow: (controller, action) async {
                final url = action.request.url;

                if (url != null) {
                  await controller.loadUrl(
                    urlRequest: URLRequest(url: url),
                  );
                }

                return false;
              },
            ),

            if (_isLoading || _isCheckingStatus)
              Container(
                color: Colors.black.withOpacity(0.08),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingWidget(),
                    if (_isCheckingStatus) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Checking payment status...',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}