import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../core/crud/crud_repository.dart';

class SupabaseCrudRepository implements CrudRepository {
  final SupabaseClient client;

  SupabaseCrudRepository({required this.client});

  @override
  FutureEither<List<Map<String, dynamic>>> list({
    required String table,
    String? orderBy,
    bool ascending = true,
    int limit = 200,
  }) async {
    try {
      final data = await client
          .from(table)
          .select('*')
          .order(orderBy ?? 'created_at', ascending: ascending)
          .limit(limit);
      return Right((data as List).cast<Map<String, dynamic>>());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to list $table: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid insert({required String table, required Map<String, dynamic> payload}) async {
    try {
      await client.from(table).insert(payload);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Insert failed for $table: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid update({
    required String table,
    required String idColumn,
    required dynamic id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await client.from(table).update(payload).eq(idColumn, id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Update failed for $table: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid delete({
    required String table,
    required String idColumn,
    required dynamic id,
  }) async {
    try {
      await client.from(table).delete().eq(idColumn, id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Delete failed for $table: $e', statusCode: 500));
    }
  }
}

