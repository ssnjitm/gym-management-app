import '../../../../core/utils/typedefs.dart';
import '../entities/member_detail_entity.dart';
import '../repositories/member_detail_repository.dart';

class GetMemberDetailUseCase {
  final MemberDetailRepository repository;

  GetMemberDetailUseCase({required this.repository});

  FutureEither<MemberDetailEntity> call({required String memberId}) {
    return repository.getMemberDetail(memberId: memberId);
  }
}

