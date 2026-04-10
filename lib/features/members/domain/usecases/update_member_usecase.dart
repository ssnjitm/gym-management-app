import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

class UpdateMemberUseCase {
  final MemberRepository repository;
  
  UpdateMemberUseCase({required this.repository});

  Future<Either<Failure, MemberEntity>> call({
    required String memberId,
    required Map<String, dynamic> memberData,
  }) {
    return repository.updateMember(
      memberId: memberId,
      memberData: memberData,
    );
  }
}
