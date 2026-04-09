import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetExpiringMembers implements UseCase<List<ExpiringMember>, String> {
  final HomeRepository repository;
  
  GetExpiringMembers(this.repository);
  
  @override
  Future<Either<Failure, List<ExpiringMember>>> call(String gymId) async {
    return await repository.getExpiringMembers(gymId);
  }
}