import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

class EnrollmentDialogController {
  final Rx<_DialogState> _state =
      _DialogState.loading(title: 'Loading…', subtitle: '').obs;

  void showLoading({required String title, String? subtitle}) {
    _state.value = _DialogState.loading(title: title, subtitle: subtitle ?? '');
  }

  void showSuccess({required String title, String? subtitle}) {
    _state.value = _DialogState.success(title: title, subtitle: subtitle ?? '');
  }

  void showFailure({required String title, String? subtitle}) {
    _state.value = _DialogState.failure(title: title, subtitle: subtitle ?? '');
  }

  void showInfo({required String title, String? subtitle}) {
    _state.value = _DialogState.info(title: title, subtitle: subtitle ?? '');
  }
}

class EnrollmentDialog extends StatelessWidget {
  final EnrollmentDialogController controller;
  const EnrollmentDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      alignment: Alignment.center, // Ensure dialog is centered
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        final s = controller._state.value;
        final bool isLoading = s.type == _DialogType.loading;
        final bool isSuccess = s.type == _DialogType.success;
        final bool isFailure = s.type == _DialogType.failure;
        final bool isInfo = s.type == _DialogType.info;

        // Determine colors based on state
        Color primaryColor;
        Color blobColor;

        if (isLoading) {
          primaryColor = const Color(0xFF6366F1); // Indigo
          blobColor = const Color(0xFF818CF8);
        } else if (isSuccess) {
          primaryColor = const Color(0xFF10B981); // Emerald
          blobColor = const Color(0xFF34D399);
        } else if (isInfo) {
          primaryColor = const Color(0xFF3B82F6); // Blue
          blobColor = const Color(0xFF60A5FA);
        } else {
          primaryColor = const Color(0xFFEF4444); // Red
          blobColor = const Color(0xFFF87171);
        }

        return ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
          child: CustomBlobBackground(
            backgroundColor: Colors.white.withOpacity(0.95),
            blobColor: blobColor,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (c, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: c),
                      ),
                      child: isLoading
                          ? _BubbleLoader(
                        key: const ValueKey('loading'),
                        color: primaryColor,
                      )
                          : isSuccess
                          ? Icon(Icons.celebration_rounded,
                          key: const ValueKey('success'),
                          size: 40,
                          color: primaryColor)
                          : isInfo
                          ? Icon(Icons.info_rounded,
                          key: const ValueKey('info'),
                          size: 40,
                          color: primaryColor)
                          : Icon(Icons.error_rounded,
                          key: const ValueKey('failure'),
                          size: 40,
                          color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                    child: Text(s.title, textAlign: TextAlign.center),
                  ),
                  if (s.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      s.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  if (isFailure || isInfo) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

enum _DialogType { loading, success, failure, info }

class _DialogState {
  final _DialogType type;
  final String title;
  final String subtitle;

  _DialogState._(this.type, this.title, this.subtitle);

  factory _DialogState.loading({required String title, String subtitle = ''}) =>
      _DialogState._(_DialogType.loading, title, subtitle);

  factory _DialogState.success({required String title, String subtitle = ''}) =>
      _DialogState._(_DialogType.success, title, subtitle);

  factory _DialogState.failure({required String title, String subtitle = ''}) =>
      _DialogState._(_DialogType.failure, title, subtitle);

  factory _DialogState.info({required String title, String subtitle = ''}) =>
      _DialogState._(_DialogType.info, title, subtitle);
}

/// Enhanced bubbly loader with color customization
class _BubbleLoader extends StatefulWidget {
  final Color color;
  const _BubbleLoader({super.key, required this.color});

  @override
  State<_BubbleLoader> createState() => _BubbleLoaderState();
}

class _BubbleLoaderState extends State<_BubbleLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Icon(Icons.auto_awesome_rounded, size: 40, color: widget.color),
    );
  }
}