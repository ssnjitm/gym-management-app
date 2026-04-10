import 'package:fpdart/fpdart.dart';
import '../entities/member_entity.dart';
import '../../../../core/error/failure.dart';


abstract class MemberRepository {
  Future<Either<Failure, List<MemberEntity>>> getMembers({
    String? gymId,
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    bool? ascending = true,
  });

  Future<Either<Failure, MemberEntity>> getMemberById({
    required String memberId,
  });

  Future<Either<Failure, MemberEntity>> createMember({
    required String gymId,
    required Map<String, dynamic> memberData,
  });

  Future<Either<Failure, MemberEntity>> updateMember({
    required String memberId,
    required Map<String, dynamic> memberData,
  });

  Future<Either<Failure, void>> deleteMember({
    required String memberId,
  });

  Future<Either<Failure, List<MemberEntity>>> searchMembers({
    required String query,
    String? gymId,
    int limit = 20,
  });
}
