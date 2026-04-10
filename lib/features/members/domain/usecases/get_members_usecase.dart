import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

class GetMembersUseCase {
  final MemberRepository repository;
  
  GetMembersUseCase({required this.repository});

  Future<Either<Failure, List<MemberEntity>>> call({
    String? gymId,
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    bool? ascending = true,
  }) {
    return repository.getMembers(
      gymId: gymId,
      page: page,
      limit: limit,
      search: search,
      status: status,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}
