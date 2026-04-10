import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/payment_list_item_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';
import '../models/payment_list_item_model.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remote;

  PaymentsRepositoryImpl({required this.remote});

  @override
  FutureEither<List<PaymentListItemEntity>> getPayments({
    required String gymId,
    int limit = 200,
  }) async {
    try {
      final rows = await remote.getPayments(gymId: gymId, limit: limit);
      final items = rows.map(PaymentListItemModel.fromMap).toList(growable: false);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load payments: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid recordPayment({
    required String memberId,
    String? subscriptionId,
    required num amount,
    required String paymentMode,
    required DateTime paymentDate,
    String? receiptNumber,
    String? notes,
    required String recordedBy,
  }) async {
    try {
      await remote.recordPayment(
        memberId: memberId,
        subscriptionId: subscriptionId,
        amount: amount,
        paymentMode: paymentMode,
        paymentDate: paymentDate,
        receiptNumber: receiptNumber,
        notes: notes,
        recordedBy: recordedBy,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to record payment: $e', statusCode: 500));
    }
  }
}

