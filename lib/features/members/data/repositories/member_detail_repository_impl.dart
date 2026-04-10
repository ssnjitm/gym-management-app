import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/member_detail_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_related_entities.dart';
import '../../domain/repositories/member_detail_repository.dart';
import '../datasources/member_detail_remote_datasource.dart';
import '../models/member_model.dart';

class MemberDetailRepositoryImpl implements MemberDetailRepository {
  final MemberDetailRemoteDataSource remote;

  MemberDetailRepositoryImpl({required this.remote});

  MemberEntity _memberFromMap(Map<String, dynamic> map) {
    return MemberModel.fromMap(map).toEntity();
  }

  SubscriptionEntity? _subscriptionFromMapOrNull(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;
    final s = rows.first;
    return SubscriptionEntity(
      subscriptionId: s['subscription_id']?.toString() ?? '',
      memberId: s['member_id']?.toString() ?? '',
      packageId: s['package_id']?.toString() ?? '',
      startDate: DateTime.parse(s['start_date'].toString()),
      expiryDate: DateTime.parse(s['expiry_date'].toString()),
      status: s['status']?.toString() ?? '',
      amountPaid: (s['amount_paid'] as num?)?.toDouble() ?? 0,
      paymentMode: s['payment_mode']?.toString() ?? '',
      paymentReference: s['payment_reference']?.toString(),
      createdBy: s['created_by']?.toString() ?? '',
      createdAt: s['created_at'] != null ? DateTime.parse(s['created_at'].toString()) : DateTime.now(),
    );
  }

  List<PaymentEntity> _paymentsFromMap(List<Map<String, dynamic>> rows) {
    return rows.map((p) {
      return PaymentEntity(
        paymentId: p['payment_id']?.toString() ?? '',
        memberId: p['member_id']?.toString() ?? '',
        subscriptionId: p['subscription_id']?.toString(),
        amount: (p['amount'] as num?)?.toDouble() ?? 0,
        paymentMode: p['payment_mode']?.toString() ?? '',
        paymentDate: DateTime.parse(p['payment_date'].toString()),
        receiptNumber: p['receipt_number']?.toString(),
        notes: p['notes']?.toString(),
        recordedBy: p['recorded_by']?.toString() ?? '',
        createdAt: p['created_at'] != null ? DateTime.parse(p['created_at'].toString()) : DateTime.now(),
      );
    }).toList();
  }

  List<AttendanceEntity> _attendanceFromMap(List<Map<String, dynamic>> rows) {
    return rows.map((a) {
      return AttendanceEntity(
        attendanceId: a['attendance_id']?.toString() ?? '',
        memberId: a['member_id']?.toString() ?? '',
        gymId: a['gym_id']?.toString() ?? '',
        checkInTime: DateTime.parse(a['check_in_time'].toString()),
        checkOutTime: a['check_out_time'] == null ? null : DateTime.parse(a['check_out_time'].toString()),
        markedBy: a['marked_by']?.toString() ?? '',
        attendanceDate: DateTime.parse(a['attendance_date'].toString()),
        createdAt: a['created_at'] != null ? DateTime.parse(a['created_at'].toString()) : DateTime.now(),
      );
    }).toList();
  }

  @override
  FutureEither<MemberDetailEntity> getMemberDetail({required String memberId}) async {
    try {
      final m = await remote.getMember(memberId: memberId);
      final sub = await remote.getCurrentSubscription(memberId: memberId);
      final pay = await remote.getPayments(memberId: memberId);
      final att = await remote.getAttendance(memberId: memberId);

      return Right(
        MemberDetailEntity(
          member: _memberFromMap(m),
          currentSubscription: _subscriptionFromMapOrNull(sub),
          payments: _paymentsFromMap(pay),
          attendance: _attendanceFromMap(att),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load member detail: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid recordPayment({
    required String memberId,
    required String? subscriptionId,
    required double amount,
    required String paymentMode,
    required DateTime paymentDate,
    required String? receiptNumber,
    required String? notes,
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
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to record payment: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid renewSubscription({
    required String memberId,
    required String packageId,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amountPaid,
    required String paymentMode,
    required String? paymentReference,
    required String createdBy,
  }) async {
    try {
      await remote.renewSubscription(
        memberId: memberId,
        packageId: packageId,
        startDate: startDate,
        expiryDate: expiryDate,
        amountPaid: amountPaid,
        paymentMode: paymentMode,
        paymentReference: paymentReference,
        createdBy: createdBy,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to renew subscription: $e', statusCode: 500));
    }
  }
}

