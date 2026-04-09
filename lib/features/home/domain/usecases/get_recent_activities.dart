import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetRecentActivities implements UseCase<List<RecentActivity>, String> {
  final HomeRepository repository;
  
  GetRecentActivities(this.repository);
  
  @override
  Future<Either<Failure, List<RecentActivity>>> call(String gymId) async {
    return await repository.getRecentActivities(gymId);
  }
}