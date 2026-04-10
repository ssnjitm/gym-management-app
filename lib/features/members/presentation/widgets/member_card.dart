import 'package:flutter/material.dart';
import '../../../../core/themes/color_schemes.dart';
import '../../domain/entities/member_entity.dart';

class MemberCard extends StatelessWidget {
  final MemberEntity member;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with Status Indicator
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                        ),
                        child: Center(
                          child: member.profilePhotoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    member.profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              : Text(
                                  member.fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getStatusColor(member.status),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Member Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tag, size: 14, color: AppColors.grey500),
                                const SizedBox(width: 4),
                                Text(
                                  member.memberCode,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: AppColors.grey500),
                                const SizedBox(width: 4),
                                Text(
                                  member.phone,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(member.status),
                      ],
                    ),
                  ),
                  
                  // Actions
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.more_vert, color: AppColors.grey400),
                    onPressed: () {
                      _showActionMenu(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Edit Member'),
                onTap: () {
                  Navigator.pop(context);
                  if (onEdit != null) onEdit!();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_outlined, color: AppColors.info),
                title: const Text('Attendance History'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment_outlined, color: AppColors.success),
                title: const Text('Payment History'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete Member'),
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete!();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.grey500;
      case 'expired':
        return AppColors.error;
      case 'grace':
        return AppColors.warning;
      default:
        return AppColors.grey500;
    }
  }
}
