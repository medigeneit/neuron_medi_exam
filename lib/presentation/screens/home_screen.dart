import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/data/models/slide_items_model.dart';
import 'package:medi_exam/data/services/active_batch_courses_service.dart';
import 'package:medi_exam/data/services/slide_items_service.dart';
import 'package:medi_exam/presentation/widgets/coming_soon_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/available_course_container_widget.dart';
import 'package:medi_exam/presentation/widgets/helpers/home_screen_helpers.dart';
import '../widgets/image_slider_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActiveBatchCoursesService _coursesService = ActiveBatchCoursesService();
  final SlidingItemsService _slidingItemsService = SlidingItemsService();
  CoursesModel? _batchCourses;
  SlideItemsModel? _slideItemsModel;
  bool _isLoading = true;
  bool _isSlidingLoading = true;
  String? _errorMessage;
  String? _slidingErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchBatchCourses(),
      _fetchSlidingItems(),
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
          _slidingErrorMessage = response.errorMessage ?? 'Failed to load slides';
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

  void _refreshData() {
    setState(() {
      _isLoading = true;
      _isSlidingLoading = true;
      _errorMessage = null;
      _slidingErrorMessage = null;
      _batchCourses = null;
      _slideItemsModel = null;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      child: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColor.primaryColor,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        child: CustomScrollView(
          slivers: [
            // Header with subtle gradient
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Neuron Exam',
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

            // Slider Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 16,
                ),
                child: _buildSliderSection(),
              ),
            ),

            // Courses Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 8,
                ),
                child: _buildCoursesSection(),
              ),
            ),

            // Coming Soon Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 8,
                ),
                child: ComingSoonWidget(
                  title: "Subject Wise Preparation",
                  isBatch: false,
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSection() {
    if (_isSlidingLoading) {
      return SliderShimmerLoading();
    } else if (_slidingErrorMessage != null) {
      return SliderErrorWidget(
        errorMessage: _slidingErrorMessage!,
        onRetry: _fetchSlidingItems,
      );
    } else if (_slideItemsModel?.slideItems?.isEmpty ?? true) {
      return SliderEmptyWidget();
    } else {
      return ImageSliderBanner(
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
        onRetry: _fetchBatchCourses,
        isBatch: true,
      );
    } else if (_batchCourses?.courses?.isEmpty ?? true) {
      return EmptyWidget(
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




