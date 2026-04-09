import 'package:fpdart/fpdart.dart';
import '../../domain/entities/staff_entity.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<Staff, LoginParams> {
  final AuthRepository authRepository;
  
  LoginUseCase(this.authRepository);
  
  @override
  Future<Either<Failure, Staff>> call(LoginParams params) async {
    return await authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;
  
  LoginParams({
    required this.email,
    required this.password,
  });
}