import '../../../../core/utils/typedefs.dart';
import '../entities/staff_entity.dart';

abstract class AuthRepository {
  FutureEither<Staff> login({
    required String email,
    required String password,
  });
  
  FutureVoid logout();
  
  FutureEither<Staff> getCurrentStaff();
  
  FutureEither<bool> isLoggedIn();
  
  FutureEither<bool> enableBiometric({required bool enable});
  
  FutureEither<bool> isBiometricEnabled();
}