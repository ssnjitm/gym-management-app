import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetDashboardStats implements UseCase<DashboardStats, String> {
  final HomeRepository repository;
  
  GetDashboardStats(this.repository);
  
  @override
  Future<Either<Failure, DashboardStats>> call(String gymId) async {
    return await repository.getDashboardStats(gymId);
  }
}