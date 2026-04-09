import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthData({
    required String accessToken,
    required String staffId,
    required String email,
  });
  
  Future<void> clearAuthData();
  
  String? getAccessToken();
  String? getStaffId();
  String? getStaffEmail();
  bool isLoggedIn();
  
  Future<void> setBiometricEnabled(bool enabled);
  bool isBiometricEnabled();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<void> saveAuthData({
    required String accessToken,
    required String staffId,
    required String email,
  }) async {
    await sharedPreferences.setString(AppConstants.keyAccessToken, accessToken);
    await sharedPreferences.setString(AppConstants.keyStaffId, staffId);
    await sharedPreferences.setString(AppConstants.keyStaffEmail, email);
    await sharedPreferences.setBool(AppConstants.keyIsLoggedIn, true);
  }
  
  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(AppConstants.keyAccessToken);
    await sharedPreferences.remove(AppConstants.keyStaffId);
    await sharedPreferences.remove(AppConstants.keyStaffEmail);
    await sharedPreferences.setBool(AppConstants.keyIsLoggedIn, false);
  }
  
  @override
  String? getAccessToken() => sharedPreferences.getString(AppConstants.keyAccessToken);
  
  @override
  String? getStaffId() => sharedPreferences.getString(AppConstants.keyStaffId);
  
  @override
  String? getStaffEmail() => sharedPreferences.getString(AppConstants.keyStaffEmail);
  
  @override
  bool isLoggedIn() => sharedPreferences.getBool(AppConstants.keyIsLoggedIn) ?? false;
  
  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await sharedPreferences.setBool(AppConstants.keyBiometricEnabled, enabled);
  }
  
  @override
  bool isBiometricEnabled() => sharedPreferences.getBool(AppConstants.keyBiometricEnabled) ?? false;
}