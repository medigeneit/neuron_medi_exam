class Urls {
  //static const String _baseUrl = "https://api.genesisedu.info/api/";
  ///local url
  static const String _baseUrl = "http://192.168.33.224:8000/api/";

  static const String allBatchCourses = "${_baseUrl}batch-courses";
  static const String activeBatchCourses = "${_baseUrl}active-batch-courses";
  static const String slider = "${_baseUrl}hero-slider";


  static String courseSession(String coursePackageId) {
    return "${_baseUrl}batches/course-package/$coursePackageId";
  }

  static String batchDetails(String batchId, String coursePackageId) {
    return "${_baseUrl}batch/$batchId/course-package/$coursePackageId";
  }


}

