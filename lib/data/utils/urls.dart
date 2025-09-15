class Urls {
  // You already have this base; keep/change as needed
  // static const String _baseUrl = "https://api.genesisedu.info/api/";
  static const String _baseUrl = "http://192.168.33.224:8000/api/";

  // ===== AUTH =====
  static const String login = "${_baseUrl}login";
  static const String registerStart = "${_baseUrl}register/start";
  static const String registerVerify = "${_baseUrl}register/verify";
  static const String registerComplete = "${_baseUrl}register/complete";

  // ===== Other APIs you already had =====
  static const String allBatchCourses = "${_baseUrl}batch-courses";
  static const String activeBatchCourses = "${_baseUrl}active-batch-courses";
  static const String slider = "${_baseUrl}hero-slider";

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
}
