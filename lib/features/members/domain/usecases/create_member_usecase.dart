import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

class CreateMemberUseCase {
  final MemberRepository repository;
  
  CreateMemberUseCase({required this.repository});

  Future<Either<Failure, MemberEntity>> call({
    required String gymId,
    required Map<String, dynamic> memberData,
  }) {
    return repository.createMember(
      gymId: gymId,
      memberData: memberData,
    );
  }
}