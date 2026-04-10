import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/member_remote_datasource.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/entities/member_entity.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource remoteDataSource;
  
  MemberRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MemberEntity>>> getMembers({
    String? gymId,
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    bool? ascending = true,
  }) async {
    try {
      final memberModels = await remoteDataSource.getMembers(
        gymId: gymId,
        page: page,
        limit: limit,
        search: search,
        status: status,
        sortBy: sortBy,
        ascending: ascending,
      );
      
      final memberEntities = memberModels.map((model) => model.toEntity()).toList();
      return Right(memberEntities);
      
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to fetch members: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, MemberEntity>> getMemberById({
    required String memberId,
  }) async {
    try {
      final memberModel = await remoteDataSource.getMemberById(memberId: memberId);
      return Right(memberModel.toEntity());
      
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to fetch member: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, MemberEntity>> createMember({
    required String gymId,
    required Map<String, dynamic> memberData,
  }) async {
    try {
      final memberModel = await remoteDataSource.createMember(
        gymId: gymId,
        memberData: memberData,
      );
      return Right(memberModel.toEntity());
      
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to create member: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, MemberEntity>> updateMember({
    required String memberId,
    required Map<String, dynamic> memberData,
  }) async {
    try {
      final memberModel = await remoteDataSource.updateMember(
        memberId: memberId,
        memberData: memberData,
      );
      return Right(memberModel.toEntity());
      
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to update member: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMember({
    required String memberId,
  }) async {
    try {
      await remoteDataSource.deleteMember(memberId: memberId);
      return const Right(null);
      
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to delete member: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<MemberEntity>>> searchMembers({
    required String query,
    String? gymId,
    int limit = 20,
  }) async {
    try {
      final memberModels = await remoteDataSource.searchMembers(
        query: query,
        gymId: gymId,
        limit: limit,
      );
      
      final memberEntities = memberModels.map((model) => model.toEntity()).toList();
      return Right(memberEntities);
      
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to search members: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }
}
