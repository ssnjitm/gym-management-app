class Staff {
  final String staffId;
  final String gymId;  // Add this field
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  Staff({
    required this.staffId,
    required this.gymId,  // Add this parameter
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });
}