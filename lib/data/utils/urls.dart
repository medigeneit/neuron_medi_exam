class Urls {

  static const String _baseUrl = "https://api.neuronpg.com/api/";
  //static const String _baseUrl = "http://192.168.33.224:8000/api/";

  // ===== AUTH =====
  static const String login = "${_baseUrl}login";
  static const String registerStart = "${_baseUrl}register/start";
  static const String registerVerify = "${_baseUrl}register/verify";
  static const String registerComplete = "${_baseUrl}register/complete";
  static const String forgotPasswordRequestOtp = "${_baseUrl}forgot-password/request-otp";
  static const String forgotPasswordVerifyOtp = "${_baseUrl}forgot-password/verify-otp";
  static const String forgotPasswordReset = "${_baseUrl}forgot-password/reset";

  static const String allBatchCourses = "${_baseUrl}batch-courses";
  static const String activeBatchCourses = "${_baseUrl}active-batch-courses";
  static const String slider = "${_baseUrl}hero-slider";
  static const String noticeList = "${_baseUrl}notices";
  static const String allEnrolledBatches = "${_baseUrl}doctor/admission-batches";
  static const String singleAnswerSubmit = "${_baseUrl}doctor/submit-answer";
  static const String helpLine = "${_baseUrl}public-settings";
  static const String changePassword = "${_baseUrl}doctor/profile/change-password";
  static const String doctorProfile = "${_baseUrl}doctor/profile";
  static const String doctorProfileUpdate = "${_baseUrl}doctor/profile/update";
  static const String paymentHistory = "${_baseUrl}doctor/admission-payments";
  static const String manualPayments = "${_baseUrl}doctor/admission-manual-payments";


  static String noticeDetails(String noticeId) {
    return "${_baseUrl}notices/$noticeId";
  }

  static String courseSession(String coursePackageId) {
    return "${_baseUrl}batches/course-package/$coursePackageId";
  }

  static String batchDetails(String batchId, String coursePackageId) {
    return "${_baseUrl}batch/$batchId/course-package/$coursePackageId";
  }

  static String batchSchedule(String batchPackageId) {
    return "${_baseUrl}batch-packages/$batchPackageId/schedule";
  }

  static String batchEnroll(String batchPackageId) {
    return "${_baseUrl}doctor/enroll/batch-package/$batchPackageId";
  }

  static String paymentDetails(String admissionId) {
    return "${_baseUrl}doctor/admission-batch-payment/$admissionId";
  }

  static String doctorSchedule(String admissionId) {
    return "${_baseUrl}doctor/admission/$admissionId/schedule";
  }

  static String invoice(String admissionId) {
    return "${_baseUrl}payment-details-pdf/$admissionId";
  }

  static String solveVideo(String admissionId, String solveVideoID) {
    return "${_baseUrl}doctor/exam-solve-show/$admissionId/$solveVideoID";
  }

  static String examProperty(String admissionId, String examId) {
    return "${_baseUrl}doctor/exam-questions-property/$admissionId/$examId";
  }

  static String examQuestion(String admissionId, String examId) {
    return "${_baseUrl}doctor/exam-questions/$admissionId/$examId";
  }


  static String finishExam(String admissionId, String examId) {
    return "${_baseUrl}doctor/exam-finish/$admissionId/$examId";
  }


  static String examFeedback(String admissionId, String examId) {
    return "${_baseUrl}doctor/submit-exam-feedback/$admissionId/$examId";
  }

  static String examResult(String admissionId, String examId) {
    return "${_baseUrl}doctor/result/$admissionId/$examId";
  }


  static String examAnswers(String admissionId, String examId) {
    return "${_baseUrl}doctor/exam-question-result/$admissionId/$examId";
  }


}
