// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:medi_exam/data/models/active_course_specialties_subjects_model.dart'; // ✅ NEW
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/data/models/helpline_model.dart';
import 'package:medi_exam/data/models/slide_items_model.dart';
import 'package:medi_exam/data/services/active_batch_courses_service.dart';
import 'package:medi_exam/data/services/active_course_specialties_subjects_service.dart'; // ✅ NEW
import 'package:medi_exam/data/services/helpline_service.dart';
import 'package:medi_exam/data/services/slide_items_service.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/available_course_container_widget.dart';
import 'package:medi_exam/presentation/widgets/floating_customer_care.dart';
import 'package:medi_exam/presentation/widgets/free_exam_card.dart';
import 'package:medi_exam/presentation/widgets/free_exam_notify_dialog.dart';
import 'package:medi_exam/presentation/widgets/helpers/batch_details_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/helpers/home_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/image_slider_banner.dart';
import 'package:medi_exam/presentation/widgets/youtube_video_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActiveBatchCoursesService _coursesService = ActiveBatchCoursesService();

  // ✅ UPDATED: active-course-specialties-subjects service
  final ActiveCourseSpecialtiesSubjectsService _specialtiesSubjectsService =
  ActiveCourseSpecialtiesSubjectsService();

  final SlidingItemsService _slidingItemsService = SlidingItemsService();
  final HelplineService _helplineService = HelplineService();

  CoursesModel? _batchCourses; // isBatch = true section

  // ✅ Subject-wise UI will still be shown using CoursesModel,
  // but populated by converting ActiveCourseSpecialtiesSubjectsModel -> CoursesModel
  CoursesModel? _subjectCourses;

  // ✅ NEW: keep subjects list to pass to next screen later
  List<Subject> _subjects = [];

  SlideItemsModel? _slideItemsModel;
  HelplineModel? _helpline;

  bool _isLoading = true; // batch-wise
  bool _isSubjectLoading = true; // subject-wise
  bool _isSlidingLoading = true;
  bool _isHelplineLoading = true;

  String? _errorMessage; // batch-wise
  String? _subjectErrorMessage; // subject-wise
  String? _slidingErrorMessage;
  String? _helplineError;


  @override
  void initState() {
    super.initState();
    _fetchData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FreeExamNotifyDialogManager.maybeShow(context: context);
    });

  }

  Future<void> _fetchData() async {
    await Future.wait([
      _checkForUpdate(),
      _fetchBatchCourses(),
      _fetchSubjectWiseSpecialtiesAndSubjects(), // ✅ UPDATED
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

  // ✅ UPDATED: Subject-wise uses active-course-specialties-subjects
  Future<void> _fetchSubjectWiseSpecialtiesAndSubjects() async {
    try {
      final response =
      await _specialtiesSubjectsService.fetchActiveCourseSpecialtiesSubjects();

      if (response.isSuccess && response.responseData != null) {
        final model =
        response.responseData as ActiveCourseSpecialtiesSubjectsModel;

        // ✅ keep subjects for next screen later
        final subjects = model.subjects ?? [];

        // ✅ Convert courses(specialties) -> CoursesModel for UI
        final converted = _convertActiveCoursesToCoursesModel(model.courses ?? []);

        setState(() {
          _subjects = subjects;
          _subjectCourses = converted;
        });
      } else {
        setState(() {
          _subjectErrorMessage =
              response.errorMessage ?? 'Failed to load subject specialties';
        });
      }
    } catch (e) {
      setState(() {
        _subjectErrorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubjectLoading = false;
      });
    }
  }

  /// ✅ Convert:
  /// ActiveCourse(courseId, courseName, specialty[]) -> Course(courseId, courseName, package[])
  /// Specialty(specialtyId, specialtyName) -> Package(packageId, packageName)
  CoursesModel _convertActiveCoursesToCoursesModel(List<ActiveCourse> list) {
    final convertedCourses = list.map((c) {
      final packages = (c.specialty ?? [])
          .map((s) => Package(
        packageId: s.specialtyId,
        packageName: s.specialtyName,
      ))
          .toList();

      return Course(
        courseId: c.courseId,
        courseName: c.courseName,
        package: packages,
      );
    }).toList();

    return CoursesModel(courses: convertedCourses);
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
      _isSubjectLoading = true;
      _isSlidingLoading = true;
      _isHelplineLoading = true;

      _errorMessage = null;
      _subjectErrorMessage = null;
      _slidingErrorMessage = null;
      _helplineError = null;

      _batchCourses = null;
      _subjectCourses = null;
      _subjects = [];
      _slideItemsModel = null;
      _helpline = null;
    });
    _fetchData();
  }

  // ---------- Promo Video helpers ----------
  bool get _isDesktopLike {
    final w = MediaQuery.of(context).size.width;
    return w >= 900;
  }

  String? _extractYouTubeId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final u = url.trim();

    final patterns = <RegExp>[
      RegExp(r'youtu\.be/([A-Za-z0-9_-]{6,})'),
      RegExp(r'youtube\.com/watch\?v=([A-Za-z0-9_-]{6,})'),
      RegExp(r'youtube\.com/embed/([A-Za-z0-9_-]{6,})'),
      RegExp(r'youtube\.com/shorts/([A-Za-z0-9_-]{6,})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(u);
      if (m != null && m.groupCount >= 1) return m.group(1);
    }
    return null;
  }

  Future<void> _handlePromoTap() async {
    final link = (_helpline?.promotionalVideoUrl ?? '').trim();
    final videoId = _extractYouTubeId(link);

    if (!_isDesktopLike && videoId != null) {
      _showYouTubeDialog(videoId);
      return;
    }

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

  String? _cleanWhatsapp(String? raw) {
    if (raw == null) return null;
    final s = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return s.isEmpty ? null : s;
  }

  String? _cleanPhone(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    return s.isEmpty ? null : s;
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await _performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          debugPrint('Flexible update available but not implemented');
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  Future<void> _performImmediateUpdate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.success) {
        debugPrint('Update successful');
      } else {
        debugPrint('Update failed with result: $result');
      }
    } catch (e) {
      debugPrint('Immediate update failed: $e');
    }
  }

  // ---------------- Free Exam handler (auth + navigation) ----------------
  Future<void> _onFreeExamPressed() async {
    final authed = await AuthChecker.to.isAuthenticated();

    Future<void> goNow() async {
      Get.toNamed(
        RouteNames.freeExams,
        arguments: {'url': Urls.openExamList},
        preventDuplicates: true,
      );
    }

    if (!authed) {
      Get.snackbar(
        'Login Required',
        'Please log in to try the free exam',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      final result = await Get.toNamed(
        RouteNames.login,
        arguments: {
          'popOnSuccess': true,
          'returnRoute': null,
          'returnArguments': null,
          'message': "You’re one step away! Log in to take the Free Exam.",
        },
      );

      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 300));
        final isNowAuthenticated = await AuthChecker.to.isAuthenticated();
        if (isNowAuthenticated) {
          await goNow();
        }
      }
      return;
    }

    await goNow();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColor.primaryColor,
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

              // ✅ Batch Wise Preparation (isBatch = true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: _buildCoursesSection(
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    model: _batchCourses,
                    showFreeExamRibbon: true,
                    title: "Batch Wise Preparation",
                    subtitle:
                    "Choose a batch and try free exams to check your level",
                    isBatch: true,
                  ),
                ),
              ),

/*              // Free exam card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: FreeExamCardButton(
                    onTap: _onFreeExamPressed,
                  ),
                ),
              ),*/

              // ✅ Subject Wise Preparation uses active-course-specialties-subjects
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: _buildCoursesSection(
                    isLoading: _isSubjectLoading,
                    errorMessage: _subjectErrorMessage,
                    model: _subjectCourses,
                    showFreeExamRibbon: true,
                    title: "Subject Wise Preparation",
                    subtitle: "Explore any subject with free exam every day",
                    isBatch: false,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),

        // Floating Customer Care
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingCustomerCare(
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

  // ✅ Reusable section builder (used for BOTH batch + subject sections)
  // ✅ UPDATED: for subject-wise, pass Subject list to next screen (implement later)
  Widget _buildCoursesSection({
    required bool isLoading,
    required String? errorMessage,
    required CoursesModel? model,
    required String title,
    required String subtitle,
    required bool showFreeExamRibbon,
    required bool isBatch,
  }) {
    if (isLoading) {
      return CoursesShimmerLoading();
    } else if (errorMessage != null) {
      return BatchErrorWidget(
        title: title,
        errorMessage: errorMessage,
        onRetry: _refreshData,
        isBatch: isBatch,
      );
    } else if (model?.courses?.isEmpty ?? true) {
      return EmptyWidget(
        title: title,
        isBatch: isBatch,
      );
    } else {
      return AvailableCourseContainerWidget(
        title: title,
        subtitle: subtitle,
        batchCourses: model!,
        isBatch: isBatch,
        showFreeExamRibbon: showFreeExamRibbon,
        onPackagePicked: ({
          required bool isBatch,
          required String courseTitle,
          required IconData icon,
          required Package package,
        }) {
          if (isBatch) {
            // ✅ Batch-wise navigation
            Get.toNamed(
              RouteNames.session_wise_batches,
              arguments: {
                'courseTitle': courseTitle,
                'icon': icon,
                'title': package.packageName,
                'isBatch': isBatch,
                'coursePackageId': package.packageId,
              },
            );
          } else {
            // ✅ Subject-wise

            Get.toNamed(
              RouteNames.subjectWisePreparation,
              arguments: {
                'courseTitle': courseTitle,
                'icon': icon,
                'specialtyId': package.packageId,
                'specialtyName': package.packageName,
                'subjects': _subjects, // List<Subject>
              },
            );

/*            //If you don't have the route yet, you can keep snackbar for now:
            Get.snackbar(
              "Course: $courseTitle",
              "Specialty: ${package.packageName} selected",
              backgroundColor: Colors.blue,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );*/
          }
        },
      );
    }
  }
}
