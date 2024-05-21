class ApiUrl {
  static final ApiUrl _instance = ApiUrl._internal();

  factory ApiUrl() {
    return _instance;
  }

  ApiUrl._internal();

  String baseUrl = "https://test.sharefood.my.id/";
}