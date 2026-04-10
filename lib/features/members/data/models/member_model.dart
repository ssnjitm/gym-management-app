import '../../domain/entities/member_entity.dart';

class MemberModel {
  final String memberId;
  final String gymId;
  final String memberCode;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final String? profilePhotoUrl;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime joinedDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  MemberModel({
    required this.memberId,
    required this.gymId,
    required this.memberCode,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    this.profilePhotoUrl,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.dateOfBirth,
    this.gender,
    required this.joinedDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      memberId: map['member_id']?.toString() ?? '',
      gymId: map['gym_id']?.toString() ?? '',
      memberCode: map['member_code']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString(),
      address: map['address']?.toString(),
      profilePhotoUrl: map['profile_photo_url']?.toString(),
      emergencyContactName: map['emergency_contact_name']?.toString(),
      emergencyContactPhone: map['emergency_contact_phone']?.toString(),
      dateOfBirth: map['date_of_birth'] != null 
          ? DateTime.parse(map['date_of_birth'].toString()) 
          : null,
      gender: map['gender']?.toString(),
      joinedDate: map['joined_date'] != null 
          ? DateTime.parse(map['joined_date'].toString()) 
          : DateTime.now(),
      status: map['status']?.toString() ?? 'active',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'].toString()) 
          : DateTime.now(),
      notes: map['notes']?.toString(),
    );
  }

  MemberEntity toEntity() {
    return MemberEntity(
      memberId: memberId,
      gymId: gymId,
      memberCode: memberCode,
      fullName: fullName,
      phone: phone,
      email: email,
      address: address,
      profilePhotoUrl: profilePhotoUrl,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      dateOfBirth: dateOfBirth,
      gender: gender,
      joinedDate: joinedDate,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
      subscriptions: null, // Will be loaded separately
      payments: null, // Will be loaded separately
      attendanceRecords: null, // Will be loaded separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'gym_id': gymId,
      'member_code': memberCode,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'profile_photo_url': profilePhotoUrl,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'joined_date': joinedDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
