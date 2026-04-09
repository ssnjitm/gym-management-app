class AppConstants {
  static const String appName = 'FitManager';
  static const String appVersion = '1.0.0';
  
  // Database names
  static const String databaseName = 'fitmanager.db';
  static const int databaseVersion = 1;
  
  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyStaffId = 'staff_id';
  static const String keyStaffEmail = 'staff_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyBiometricEnabled = 'biometric_enabled';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Timeouts
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  
  //error messages
  static const String noConnectionErrorMessage = 'No internet connection. Please check your network.';
  static const String serverErrorMessage = 'Something went wrong. Please try again.';
  static const String loginFailedMessage = 'Login failed. Please check your credentials.';
  static const String unauthorizedMessage = 'Unauthorized. Please login again.';
}