// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/data/models/slide_items_model.dart';
import 'package:medi_exam/data/models/helpline_model.dart';
import 'package:medi_exam/data/services/active_batch_courses_service.dart';
import 'package:medi_exam/data/services/slide_items_service.dart';
import 'package:medi_exam/data/services/helpline_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/available_course_container_widget.dart';
import 'package:medi_exam/presentation/widgets/coming_soon_widget.dart';
import 'package:medi_exam/presentation/widgets/floating_customer_care.dart';
import 'package:medi_exam/presentation/widgets/helpers/home_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/image_slider_banner.dart';
import 'package:medi_exam/presentation/widgets/youtube_video_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActiveBatchCoursesService _coursesService = ActiveBatchCoursesService();
  final SlidingItemsService _slidingItemsService = SlidingItemsService();
  final HelplineService _helplineService = HelplineService();

  CoursesModel? _batchCourses;
  SlideItemsModel? _slideItemsModel;
  HelplineModel? _helpline;

  bool _isLoading = true;
  bool _isSlidingLoading = true;
  bool _isHelplineLoading = true;

  String? _errorMessage;
  String? _slidingErrorMessage;
  String? _helplineError;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchBatchCourses(),
      _fetchSlidingItems(),
      _fetchHelpline(),
    ]);
  }

  Future<void> _fetchBatchCourses() async {
    try {
      final response = await _coursesService.fetchActiveBatchCourses();

      if (response.isSuccess && response.responseData != null) {
        setState(() {
          _batchCourses = response.responseData as CoursesModel;
        });
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load courses';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSlidingItems() async {
    try {
      final response = await _slidingItemsService.fetchSlidingItems();

      if (response.isSuccess && response.responseData != null) {
        setState(() {
          _slideItemsModel = response.responseData as SlideItemsModel;
        });
      } else {
        setState(() {
          _slidingErrorMessage =
              response.errorMessage ?? 'Failed to load slides';
        });
      }
    } catch (e) {
      setState(() {
        _slidingErrorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSlidingLoading = false;
      });
    }
  }

  Future<void> _fetchHelpline() async {
    try {
      final response = await _helplineService.fetchHelpline();
      if (response.isSuccess && response.responseData != null) {
        setState(() {
          _helpline = response.responseData as HelplineModel;
        });
      } else {
        setState(() {
          _helplineError = response.errorMessage ?? 'Failed to load helpline';
        });
      }
    } catch (e) {
      setState(() {
        _helplineError = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isHelplineLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _isSlidingLoading = true;
      _isHelplineLoading = true;

      _errorMessage = null;
      _slidingErrorMessage = null;
      _helplineError = null;

      _batchCourses = null;
      _slideItemsModel = null;
      _helpline = null;
    });
    _fetchData();
  }

  // ---------- Promo Video helpers ----------
  // Lightweight check: try to embed on phones/tablets, open external on wide screens.
  bool get _isDesktopLike {
    final w = MediaQuery.of(context).size.width;
    return w >= 900; // tweak if you want
  }

  String? _extractYouTubeId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final u = url.trim();

    // Common YouTube patterns
    final patterns = <RegExp>[
      RegExp(r'youtu\.be/([A-Za-z0-9_-]{6,})'),
      RegExp(r'youtube\.com/watch\?v=([A-Za-z0-9_-]{6,})'),
      RegExp(r'youtube\.com/embed/([A-Za-z0-9_-]{6,})'),
      RegExp(r'youtube\.com/shorts/([A-Za-z0-9_-]{6,})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(u);
      if (m != null && m.groupCount >= 1) {
        return m.group(1);
      }
    }
    return null;
  }

  Future<void> _handlePromoTap() async {
    final link = (_helpline?.promotionalVideoUrl ?? '').trim();
    final videoId = _extractYouTubeId(link);

    // Try inline dialog on smaller screens if we can extract an ID
    if (!_isDesktopLike && videoId != null) {
      _showYouTubeDialog(videoId);
      return;
    }

    // Fallback: open externally
    if (link.isNotEmpty) {
      await _openExternal(link);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video link is unavailable')),
      );
    }
  }

  void _showYouTubeDialog(String videoId) {
    // If you don't have YouTubeVideoDialog, this try/catch will safely
    // fallback to external open.
    try {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => YouTubeVideoDialog(
          videoId: videoId,
          title: 'Tutorial Video',
        ),
      );
    } catch (_) {
      final link = (_helpline?.promotionalVideoUrl ?? '').trim();
      _openExternal(link);
    }
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  // Sanitizers (optional; keep light)
  String? _cleanWhatsapp(String? raw) {
    if (raw == null) return null;
    final s = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return s.isEmpty ? null : s;
  }

  String? _cleanPhone(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    return s.isEmpty ? null : s;
    // You could enforce "+<country><number>" here if you want.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Stack(
      children: [
        // Content
        RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColor.primaryColor,
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to ${AssetsPath.appName}',
                        style: TextStyle(
                          fontSize: Sizes.subTitleText(context),
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prepare for your medical exams with expert courses',
                        style: TextStyle(
                          fontSize: Sizes.normalText(context),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Slider
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 16,
                  ),
                  child: _buildSliderSection(),
                ),
              ),

              // Courses
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: _buildCoursesSection(),
                ),
              ),

              // Coming Soon
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: const ComingSoonWidget(
                    title: "Subject Wise Preparation",
                    isBatch: false,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),

        // 💬 Floating Customer Care (bottom-right)
        // Auto-hides individual actions if they are null/empty.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingCustomerCare(
                // All optional now; pass null/empty safely.
                messengerUrl: _helpline?.messenger,
                whatsappPhone: _cleanWhatsapp(_helpline?.whatsapp),
                phoneNumber: _cleanPhone(_helpline?.phone),
                promoVideoUrl: _helpline?.promotionalVideoUrl,
                onPromoTap: _handlePromoTap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSection() {
    if (_isSlidingLoading) {
      return SliderShimmerLoading();
    } else if (_slidingErrorMessage != null) {
      return SliderErrorWidget(
        errorMessage: _slidingErrorMessage!,
        onRetry: _refreshData,
      );
    } else if (_slideItemsModel?.slideItems?.isEmpty ?? true) {
      return SliderEmptyWidget();
    } else {
      return PromoSliderBanner(
        slideItems: _slideItemsModel!.slideItems!,
        height: 240,
      );
    }
  }

  Widget _buildCoursesSection() {
    if (_isLoading) {
      return CoursesShimmerLoading();
    } else if (_errorMessage != null) {
      return BatchErrorWidget(
        title: "Batch Wise Preparation",
        errorMessage: _errorMessage!,
        onRetry: _refreshData,
        isBatch: true,
      );
    } else if (_batchCourses?.courses?.isEmpty ?? true) {
      return const EmptyWidget(
        title: "Batch Wise Preparation",
        isBatch: true,
      );
    } else {
      return AvailableCourseContainerWidget(
        title: "Batch Wise Preparation",
        batchCourses: _batchCourses!,
        isBatch: true,
      );
    }
  }
}
