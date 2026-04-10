import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/member_repository.dart';

class DeleteMemberUseCase {
  final MemberRepository repository;
  
  DeleteMemberUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String memberId,
  }) {
    return repository.deleteMember(memberId: memberId);
  }
}
