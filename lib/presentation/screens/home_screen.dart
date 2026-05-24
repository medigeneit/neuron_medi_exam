import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';
import 'package:medi_exam/data/models/active_course_specialties_subjects_model.dart';
import 'package:medi_exam/data/models/career_guidelines_model.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/data/models/exam_property_model.dart';
import 'package:medi_exam/data/models/helpline_model.dart';
import 'package:medi_exam/data/models/open_exam_list_model.dart';
import 'package:medi_exam/data/models/slide_items_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/active_batch_courses_service.dart';
import 'package:medi_exam/data/services/active_course_specialties_subjects_service.dart';
import 'package:medi_exam/data/services/career_guidelines_service.dart';
import 'package:medi_exam/data/services/exam_property_service.dart';
import 'package:medi_exam/data/services/helpline_service.dart';
import 'package:medi_exam/data/services/open_exam_list_service.dart';
import 'package:medi_exam/data/services/public_open_exam_service.dart';
import 'package:medi_exam/data/services/slide_items_service.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/available_course_container_widget.dart';
import 'package:medi_exam/presentation/widgets/career_guideline_card.dart';
import 'package:medi_exam/presentation/widgets/career_guideline_dialog.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/easy_finder_card.dart';
import 'package:medi_exam/presentation/widgets/exam_overview_dialog.dart';
import 'package:medi_exam/presentation/widgets/floating_customer_care.dart';
import 'package:medi_exam/presentation/widgets/free_exam_notify_dialog.dart';
import 'package:medi_exam/presentation/widgets/helpers/batch_details_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/helpers/home_screen_helpers.dart';
import 'package:medi_exam/presentation/widgets/image_slider_banner.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/login_offer_dialog.dart';
import 'package:medi_exam/presentation/widgets/pinned_free_exam_banner.dart';
import 'package:medi_exam/presentation/widgets/youtube_video_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActiveBatchCoursesService _coursesService = ActiveBatchCoursesService();

  final ActiveCourseSpecialtiesSubjectsService _specialtiesSubjectsService =
  ActiveCourseSpecialtiesSubjectsService();

  final SlidingItemsService _slidingItemsService = SlidingItemsService();
  final HelplineService _helplineService = HelplineService();
  final CareerGuidelinesService _careerGuidelinesService =
  CareerGuidelinesService();

  CoursesModel? _batchCourses;
  CoursesModel? _subjectCourses;

  Map<int, List<Subject>> _subjectsBySpecialty = {};

  SlideItemsModel? _slideItemsModel;
  HelplineModel? _helpline;

  bool _isLoading = true;
  bool _isSubjectLoading = true;
  bool _isSlidingLoading = true;
  bool _isHelplineLoading = true;

  String? _errorMessage;
  String? _subjectErrorMessage;
  String? _slidingErrorMessage;
  String? _helplineError;

  final _logger = Logger();
  final PublicOpenExamService _publicOpenExamService = PublicOpenExamService();
  final OpenExamListService _doctorOpenExamService = OpenExamListService();
  final ExamPropertyService _examPropertyService = ExamPropertyService();

  bool _isPinnedLoading = true;
  String? _pinnedError;
  OpenExamModel? _pinnedExam;

  @override
  void initState() {
    super.initState();
    _fetchData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FreeExamNotifyDialogManager.maybeShow(context: context);
      LoginOfferPromptManager.maybeShow(context: context);
    });
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _checkForUpdate(),
      _fetchPinnedExam(),
      _fetchBatchCourses(),
      _fetchSubjectWiseSpecialtiesAndSubjects(),
      _fetchSlidingItems(),
      _fetchHelpline(),
    ]);
  }

  Future<void> _fetchPinnedExam() async {
    setState(() {
      _isPinnedLoading = true;
      _pinnedError = null;
      _pinnedExam = null;
    });

    try {
      final NetworkResponse res =
      await _publicOpenExamService.fetchPublicFreeOpenExams(
        Urls.openExamPublicList,
      );

      if (res.isSuccess && res.responseData is OpenExamListModel) {
        final model = res.responseData as OpenExamListModel;

        OpenExamModel? pinned;
        for (final e in model.items) {
          if (e.safeIsPinned) {
            pinned = e;
            break;
          }
        }

        setState(() {
          _pinnedExam = pinned;
        });
      } else {
        setState(() {
          _pinnedError = res.errorMessage ?? 'Failed to load pinned exam';
        });
      }
    } catch (e) {
      setState(() {
        _pinnedError = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isPinnedLoading = false;
      });
    }
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

  Future<void> _fetchSubjectWiseSpecialtiesAndSubjects() async {
    try {
      final response =
      await _specialtiesSubjectsService.fetchActiveCourseSpecialtiesSubjects();

      if (response.isSuccess && response.responseData != null) {
        final model =
        response.responseData as ActiveCourseSpecialtiesSubjectsModel;

        final courses = model.courses ?? [];

        final Map<int, List<Subject>> subjectsMap = {};
        for (final course in courses) {
          for (final sp in (course.specialties ?? [])) {
            final sid = sp.specialtyId;
            if (sid != null) {
              subjectsMap[sid] = sp.subjects ?? <Subject>[];
            }
          }
        }

        final converted = _convertActiveCoursesToCoursesModel(courses);

        setState(() {
          _subjectsBySpecialty = subjectsMap;
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

  CoursesModel _convertActiveCoursesToCoursesModel(List<ActiveCourse> list) {
    final convertedCourses = list.map((c) {
      final packages = (c.specialties ?? [])
          .map(
            (s) => Package(
          packageId: s.specialtyId,
          packageName: s.specialtyName,
        ),
      )
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
      _subjectsBySpecialty = {};
      _slideItemsModel = null;
      _helpline = null;

      _isPinnedLoading = true;
      _pinnedError = null;
      _pinnedExam = null;
    });

    await _fetchData();
  }

  String? _extractYouTubeId(String? input) {
    if (input == null) return null;

    final raw = input.trim();
    if (raw.isEmpty) return null;

    final rawIdPattern = RegExp(r'^[A-Za-z0-9_-]{6,}$');
    if (rawIdPattern.hasMatch(raw) &&
        !raw.contains('http') &&
        !raw.contains('youtube') &&
        !raw.contains('youtu.be')) {
      return raw;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments;

    if (host.contains('youtu.be')) {
      if (segments.isNotEmpty && segments.first.trim().isNotEmpty) {
        return segments.first.trim();
      }
    }

    final v = uri.queryParameters['v'];
    if (v != null && v.trim().isNotEmpty) {
      return v.trim();
    }

    final embedIndex = segments.indexOf('embed');
    if (embedIndex != -1 && embedIndex + 1 < segments.length) {
      final id = segments[embedIndex + 1].trim();
      if (id.isNotEmpty) return id;
    }

    final shortsIndex = segments.indexOf('shorts');
    if (shortsIndex != -1 && shortsIndex + 1 < segments.length) {
      final id = segments[shortsIndex + 1].trim();
      if (id.isNotEmpty) return id;
    }

    final liveIndex = segments.indexOf('live');
    if (liveIndex != -1 && liveIndex + 1 < segments.length) {
      final id = segments[liveIndex + 1].trim();
      if (id.isNotEmpty) return id;
    }

    return null;
  }

  void _showYouTubeDialog({
    required String source,
    String? title,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => YouTubeVideoDialog(
        videoId: source,
        title: title,
      ),
    );
  }

  Future<void> _handlePromoTap() async {
    final link = (_helpline?.promotionalVideoUrl ?? '').trim();
    if (link.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video link is unavailable')),
      );
      return;
    }

    final videoId = _extractYouTubeId(link);

    if (videoId != null) {
      _showYouTubeDialog(
        source: link,
        title: 'Tutorial Video',
      );
      return;
    }

    await _openExternal(link);
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

  Future<void> _onFreeExamPressed() async {
    final authed = await AuthChecker.to.isAuthenticated();

    Future<void> goNow() async {
      Get.toNamed(
        RouteNames.openExamList,
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

  Future<void> _onCareerGuidelinePressed() async {
    showCareerGuidelineLoadingDialog(context);

    try {
      final response = await _careerGuidelinesService.fetchCareerGuidelines();

      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (response.isSuccess &&
          response.responseData is CareerGuidelinesListModel) {
        final model = response.responseData as CareerGuidelinesListModel;

        if (!mounted) return;

        await showCareerGuidelineDialog(
          context: context,
          model: model,
          title: 'Post Graduation Guideline',
        );
      } else {
        Get.snackbar(
          'Failed',
          response.errorMessage ?? 'Failed to load guidelines',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      Get.snackbar(
        'Failed',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _onPinnedExamPressed() async {
    final pinned = _pinnedExam;
    if (pinned == null || pinned.safeExamId == 0) return;

    final authed = await AuthChecker.to.isAuthenticated();
    if (!authed) {
      Get.snackbar(
        'Login Required',
        'Please log in to take this pinned free exam',
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
          'message': "Log in to take the Pinned Free Exam.",
        },
      );

      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 300));
        final nowAuthed = await AuthChecker.to.isAuthenticated();
        if (!nowAuthed) return;
      } else {
        return;
      }
    }

    Get.dialog(
      const Center(
        child: CustomBlobBackground(
          backgroundColor: AppColor.whiteColor,
          blobColor: AppColor.purple,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LoadingWidget(),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final NetworkResponse res =
      await _doctorOpenExamService.fetchFreeExamList(Urls.openExamList);

      if (!res.isSuccess || res.responseData is! OpenExamListModel) {
        throw Exception(res.errorMessage ?? 'Failed to load your exam status.');
      }

      final OpenExamListModel model = res.responseData as OpenExamListModel;

      OpenExamModel? target;
      for (final e in model.items) {
        if (e.safeExamId == pinned.safeExamId) {
          target = e;
          break;
        }
      }

      target ??= pinned;

      final status = _resolveDoctorExamStatus(target);

      if (Get.isDialogOpen == true) Get.back();

      if (status == _DoctorExamResolvedStatus.completed) {
        final data = {
          'admissionId': '',
          'examId': target.safeExamId.toString(),
          'examType': 'openExam',
        };
        Get.toNamed(
          RouteNames.examResult,
          arguments: data,
          preventDuplicates: true,
        );
        return;
      }

      await _openFreeExamOverviewByExamId(target.safeExamId);
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      _logger.e('Pinned exam flow error: $e');
    }
  }

  _DoctorExamResolvedStatus _resolveDoctorExamStatus(OpenExamModel exam) {
    final list = exam.doctorOpenExam;
    if (list == null || list.isEmpty) return _DoctorExamResolvedStatus.available;

    for (final e in list) {
      final s = (e.status ?? '').toLowerCase().trim();
      if (s == 'completed') return _DoctorExamResolvedStatus.completed;
    }

    return _DoctorExamResolvedStatus.running;
  }

  Future<void> _openFreeExamOverviewByExamId(int examId) async {
    Get.dialog(
      const Center(
        child: CustomBlobBackground(
          backgroundColor: AppColor.whiteColor,
          blobColor: AppColor.purple,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LoadingWidget(),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final String eid = examId.toString();
      final String url = Urls.openExamProperty(eid);
      final NetworkResponse res =
      await _examPropertyService.fetchExamProperty(url);

      if (!res.isSuccess) {
        throw Exception(res.errorMessage ?? 'Failed to load exam property.');
      }

      late final ExamPropertyModel model;
      if (res.responseData is ExamPropertyModel) {
        model = res.responseData as ExamPropertyModel;
      } else if (res.responseData is Map<String, dynamic>) {
        model =
            ExamPropertyModel.fromJson(res.responseData as Map<String, dynamic>);
      } else {
        throw Exception('Unexpected response: ${res.responseData.runtimeType}');
      }

      if (Get.isDialogOpen == true) Get.back();

      await showExamOverviewDialog(
        context,
        model: model,
        url: Urls.openExamQuestion(eid),
        examType: 'openExam',
        admissionId: '',
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      rethrow;
    }
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 26,
                    vertical: 8,
                  ),
                  child: _buildPinnedExamSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 16,
                  ),
                  child: _buildSliderSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: const EasyFinderCard(title: 'Smart Search'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  child: CareerGuidelineCard(
                    title: 'Post Graduation Guideline',
                    subtitle: 'Browse guideline and resources instantly',
                    requireAuth: false,
                    onAuthedNavigate: _onCareerGuidelinePressed,
                  ),
                ),
              ),
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
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
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

  Widget _buildPinnedExamSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isPinnedLoading) {
      return Container(
        height: isMobile ? 86 : 96,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    if (_pinnedError != null) {
      return const SizedBox.shrink();
    }

    final pinned = _pinnedExam;
    if (pinned == null) return const SizedBox.shrink();

    final examTitle =
    pinned.safeTitle.isNotEmpty ? pinned.safeTitle : 'Pinned Free Exam';
    final courseName = pinned.course?.name ?? '';

    return PinnedFreeExamBanner(
      title: examTitle,
      subtitle: courseName.isNotEmpty
          ? 'Course: $courseName'
          : 'Tap to start/continue your pinned free exam',
      onTap: _onPinnedExamPressed,
      height: isMobile ? 72 : 82,
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
            final sid = package.packageId;
            final subjects = (sid == null)
                ? <Subject>[]
                : (_subjectsBySpecialty[sid] ?? <Subject>[]);

            Get.toNamed(
              RouteNames.subjectWisePreparation,
              arguments: {
                'courseTitle': courseTitle,
                'icon': icon,
                'specialtyId': package.packageId,
                'specialtyName': package.packageName,
                'subjects': subjects,
              },
            );
          }
        },
      );
    }
  }
}

enum _DoctorExamResolvedStatus { available, running, completed }