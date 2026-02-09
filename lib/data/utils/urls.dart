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
  static const String activeCourseSpecialties = "${_baseUrl}active-course-specialties";
  static const String activeCourseSpecialtiesSubjects = "${_baseUrl}active-course-specialties-subjects";
  static const String slider = "${_baseUrl}hero-slider";
  static const String noticeList = "${_baseUrl}notices";
  static const String allEnrolledBatches = "${_baseUrl}doctor/admission-batches";
  static const String courseExamSingleAnswerSubmit = "${_baseUrl}doctor/submit-answer";
  static const String helpLine = "${_baseUrl}public-settings";
  static const String changePassword = "${_baseUrl}doctor/profile/change-password";
  static const String doctorProfile = "${_baseUrl}doctor/profile";
  static const String doctorProfileUpdate = "${_baseUrl}doctor/profile/update";
  static const String paymentHistory = "${_baseUrl}doctor/admission-payments";
  static const String manualPayments = "${_baseUrl}doctor/admission-manual-payments";
  static const String openExamSingleAnswerSubmit = "${_baseUrl}doctor/open-exam-submit-answer";
  static const String openExamPublicList = "${_baseUrl}open-exams/free";
  static const String openExamList = "${_baseUrl}doctor/open-exam-list";
  static const String freeExamQuota = "${_baseUrl}doctor/free-exams/quota";
  static const String freeExamCreate = "${_baseUrl}doctor/free-exams/create";
  static const String freeExamSingleAnswerSubmit = "${_baseUrl}doctor/free-exams/submit-answer";
  static const String wrongSkippedQus = "${_baseUrl}doctor/dashboard/exams/summary";
  static const String favourites = "${_baseUrl}doctor/favourites";
  static const String favouritesToggleAddRemove = "${_baseUrl}doctor/favourites/add";





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

  static String openExamListCourseWise(String courseId) {
    return "${_baseUrl}doctor/open-exam-list/$courseId";
  }

  static String openExamProperty(String examId) {
    return "${_baseUrl}doctor/open-exam-questions-property/$examId";
  }
  static String openExamQuestion(String examId) {
    return "${_baseUrl}doctor/open-exam-questions/$examId";
  }

  static String openExamFeedback(String examId) {
    return "${_baseUrl}doctor/submit-open-exam-feedback/$examId";
  }

  static String finishOpenExam(String examId) {
    return "${_baseUrl}doctor/open-exam-finish/$examId";
  }

  static String openExamResult(String examId) {
    return "${_baseUrl}doctor/open-exam-result/$examId";
  }

  static String openExamAnswers(String examId) {
    return "${_baseUrl}doctor/open-exam-question-result/$examId";
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


  static String finishCourseExam(String admissionId, String examId) {
    return "${_baseUrl}doctor/exam-finish/$admissionId/$examId";
  }


  static String courseExamFeedback(String admissionId, String examId) {
    return "${_baseUrl}doctor/submit-exam-feedback/$admissionId/$examId";
  }

  static String courseExamResult(String admissionId, String examId) {
    return "${_baseUrl}doctor/result/$admissionId/$examId";
  }


  static String courseExamAnswers(String admissionId, String examId) {
    return "${_baseUrl}doctor/exam-question-result/$admissionId/$examId";
  }

  static String questionExplanation(String questionId) {
    return "${_baseUrl}doctor/questions/$questionId/explanation";
  }



  static String makeBkashPayment(String admissionId, String amount) {
    return "${_baseUrl}doctor/batch-make-bkash-payment?admission-id=$admissionId&amount=$amount";
  }

  static String subjectWiseChapterTopics(String specialtyId, String subjectId) {
    return "${_baseUrl}specialty/$specialtyId/question-subjects/$subjectId";
  }

  static String freeExamList(String pageNo) {
    return "${_baseUrl}doctor/free-exams?page=$pageNo";
  }

  static String freeExamProperty(String examId) {
    return "${_baseUrl}doctor/free-exams/$examId/property";
  }

  static String freeExamQuestion(String examId) {
    return "${_baseUrl}doctor/free-exams/$examId/questions";
  }

  static String freeExamFeedback(String examId) {
    return "${_baseUrl}doctor/free-exams/$examId/feedback";
  }

  static String finishFreeExam(String examId) {
    return "${_baseUrl}doctor/free-exams/$examId/result-submit";
  }
  static String freeExamResult(String examId) {
    return "${_baseUrl}doctor/free-exams/$examId/result";
  }

  static String freeExamAnswers(String examId) {
    return "${_baseUrl}doctor/free-exam/$examId/question-result";
  }

  static String wrongSkippedQuestion(String type, String examId) {
    return "${_baseUrl}doctor/dashboard/exams/wrong-and-unanswered?type=$type&id=$examId";
  }


}
