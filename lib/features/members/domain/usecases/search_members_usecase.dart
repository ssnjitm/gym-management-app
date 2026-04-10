import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

class SearchMembersUseCase {
  final MemberRepository repository;
  
  SearchMembersUseCase({required this.repository});

  Future<Either<Failure, List<MemberEntity>>> call({
    required String query,
    String? gymId,
    int limit = 20,
  }) {
    return repository.searchMembers(
      query: query,
      gymId: gymId,
      limit: limit,
    );
  }
}
