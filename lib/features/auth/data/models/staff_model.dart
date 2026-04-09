import 'dart:convert';
import 'package:members_management_app/features/auth/domain/entities/staff_entity.dart';

class StaffModel extends Staff {
  StaffModel({
    required super.staffId,
    required super.gymId,
    required super.fullName,
    required super.email,
    super.phone,
    required super.role,
    required super.isActive,
    required super.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'staff_id': staffId,
      'gym_id': gymId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      staffId: map['staff_id'].toString(), // Convert UUID to string
      gymId: map['gym_id'].toString(), // Convert UUID to string
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone']?.toString(),
      role: map['role'] ?? 'reception',
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }
  
  String toJson() => json.encode(toMap());
  
  factory StaffModel.fromJson(String source) => 
      StaffModel.fromMap(json.decode(source) as Map<String, dynamic>);
}