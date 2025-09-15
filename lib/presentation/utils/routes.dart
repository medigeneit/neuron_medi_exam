import 'package:get/get.dart';
import 'package:medi_exam/presentation/screens/available_batches_screen.dart';
import 'package:medi_exam/presentation/screens/batch_schedule_screen.dart';
import 'package:medi_exam/presentation/screens/change_password_screen.dart';
import 'package:medi_exam/presentation/screens/courses_screen.dart';
import 'package:medi_exam/presentation/screens/dashboard_screen.dart';
import 'package:medi_exam/presentation/screens/batch_details_screen.dart';
import 'package:medi_exam/presentation/screens/edit_profile_screen.dart';
import 'package:medi_exam/presentation/screens/enrolled_courses_screen.dart';
import 'package:medi_exam/presentation/screens/login_screen.dart';
import 'package:medi_exam/presentation/screens/navbar_screen.dart';
import 'package:medi_exam/presentation/screens/notice_screen.dart';
import 'package:medi_exam/presentation/screens/payment_screen.dart';
import 'package:medi_exam/presentation/screens/profile_section_screen.dart';
import 'package:medi_exam/presentation/screens/registration_screen.dart';
import 'package:medi_exam/presentation/screens/session_wise_batches_screen.dart';
import 'package:medi_exam/presentation/screens/splash_screen.dart';

class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgotPassword';
  static const String forgotPasswordVerification =
      '/forgotPasswordVerification';
  static const String passwordChange = '/passwordChange';
  static const String homeScreen = '/home';
  static const String navBar = '/navigation';
  static const String session_wise_batches = '/sessionWiseBatches';
  static const String courses = '/courses';
  static const String enrolledCourses = '/enrolledCourses';
  static const String support = '/support';
  static const String menu = '/menu';
  static const String availableBatches = '/availableBatches';
  static const String profile_section = '/profileSection';
  static const String dashboard = '/dashboard';
  static const String editProfile = '/editProfile';
  static const String subscriptions = '/subscriptions';
  static const String notice = '/notice';
  static const String batchDetails = '/batch_details';
  static const String batchSchedule = '/batch_schedule';
  static const String enrollment = '/enrollment';
  static const String makePayment = '/makePayment';
  static const String courseSchedule = '/courseSchedule';
  static const String complainRelatedTo = '/complainRelatedTo';
  static const String complainConversation = '/complainConversation';
  static const String deviceVerification = '/deviceVerification';
  static const String deviceVerificationOtp = '/deviceVerificationOtp';
  static const String deviceVerificationReason = '/deviceVerificationReason';
  static const String webView = '/web';
  static const String webViewVideo = '/webViewVideo';
  static const String vdoChipher = '/vdoChipher';
  static const String examInformation = '/examInformation';
  static const String examQuestion = '/examQuestion';
}

// Define routes
final List<GetPage> appRoutes = [
  GetPage(
    name: RouteNames.splash,
    page: () => const SplashScreen(),
  ),

  GetPage(
    name: RouteNames.navBar,
    page: () => const NavBarScreen(),
  ),

  GetPage(
    name: RouteNames.login,
    page: () => const LoginScreen(),
  ),

  GetPage(
    name: RouteNames.registration,
    page: () => const RegistrationScreen(),
  ),

  GetPage(
    name: RouteNames.courses,
    page: () => const CoursesScreen(),
  ),

  GetPage(
    name: RouteNames.enrolledCourses,
    page: () => const EnrolledCoursesScreen(),
  ),
  GetPage(
    name: RouteNames.notice,
    page: () => const NoticeScreen(),
  ),
  GetPage(
    name: RouteNames.availableBatches,
    page: () => const AvailableBatchesScreen(),
  ),
  GetPage(
    name: RouteNames.batchDetails,
    page: () => const BatchDetailsScreen(),
  ),

  GetPage(
    name: RouteNames.batchSchedule,
    page: () => const BatchScheduleScreen(),
  ),

  GetPage(
    name: RouteNames.session_wise_batches,
    page: () => const SessionWiseBatchesScreen(),
  ),

  // Protected routes with AuthMiddleware
  GetPage(
    name: RouteNames.dashboard,
    page: () => const Dashboard(),

  ),
  GetPage(
    name: RouteNames.profile_section,
    page: () => const ProfileSectionScreen(),
  ),
  GetPage(
    name: RouteNames.editProfile,
    page: () => const EditProfileScreen(),
  ),
  GetPage(
    name: RouteNames.passwordChange,
    page: () => const ChangePasswordScreen(),
  ),

  GetPage(
    name: RouteNames.makePayment,
    page: () => const PaymentScreen(),
  ),

];
