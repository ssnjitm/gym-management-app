import '../utils/typedefs.dart';

abstract class CrudRepository {
  FutureEither<List<Map<String, dynamic>>> list({
    required String table,
    String? orderBy,
    bool ascending = true,
    int limit = 200,
  });

  FutureVoid insert({
    required String table,
    required Map<String, dynamic> payload,
  });

  FutureVoid update({
    required String table,
    required String idColumn,
    required dynamic id,
    required Map<String, dynamic> payload,
  });

  FutureVoid delete({
    required String table,
    required String idColumn,
    required dynamic id,
  });
}

