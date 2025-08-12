import 'package:get/get.dart';
import 'package:medi_exam/presentation/screens/login_screen.dart';
import 'package:medi_exam/presentation/screens/navbar_screen.dart';
import 'package:medi_exam/presentation/screens/registration_screen.dart';
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
  static const String myCourse = '/myCourse';
  static const String support = '/support';
  static const String menu = '/menu';
  static const String availableBatches = '/availableBatches';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String subscriptions = '/subscriptions';
  static const String notice = '/notice';
  static const String batchDetails = '/batch_details';
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

];
