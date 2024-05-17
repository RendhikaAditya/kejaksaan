class ApiUrl {
  static final ApiUrl _instance = ApiUrl._internal();

  factory ApiUrl() {
    return _instance;
  }

  ApiUrl._internal();

  String baseUrl = "http://192.30.35.134/apiKejaksaan/";
}