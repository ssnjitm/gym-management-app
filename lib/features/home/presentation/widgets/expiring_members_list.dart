// Update expiring_members_list.dart
import 'package:flutter/material.dart';
import '../../../../core/themes/color_schemes.dart';
import '../../domain/entities/home_entity.dart';

class ExpiringMembersList extends StatelessWidget {
  final List<ExpiringMember> members;
  final Function(String) onRenewTap;

  const ExpiringMembersList({
    super.key,
    required this.members,
    required this.onRenewTap,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success.withOpacity(0.5), size: 48),
            const SizedBox(height: 12),
            const Text(
              'No memberships expiring soon',
              style: TextStyle(color: AppColors.grey500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: member.isUrgent ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              child: Text(
                member.daysLeft.toString(),
                style: TextStyle(
                  color: member.isUrgent ? AppColors.error : AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              member.memberName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${member.packageName} • ${member.phone}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: ElevatedButton(
              onPressed: () => onRenewTap(member.memberId),
              style: ElevatedButton.styleFrom(
                backgroundColor: member.isUrgent ? Colors.red : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Renew'),
            ),
          ),
        );
      },
    );
  }
}