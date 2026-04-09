import 'package:fpdart/fpdart.dart';
import '../../domain/entities/staff_entity.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class GetCurrentStaffUseCase implements UseCase<Staff, NoParams> {
  final AuthRepository authRepository;
  
  GetCurrentStaffUseCase(this.authRepository);
  
  @override
  Future<Either<Failure, Staff>> call(NoParams params) async {
    return await authRepository.getCurrentStaff();
  }
}