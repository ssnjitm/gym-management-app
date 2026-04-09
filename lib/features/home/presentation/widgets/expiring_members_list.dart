// Update expiring_members_list.dart
import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No members expiring soon 🎉'),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '⚠️ Expiring Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length > 5 ? 5 : members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: member.statusColor.withOpacity(0.1),
                  child: Text(
                    member.daysLeft.toString(),
                    style: TextStyle(
                      color: member.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  member.memberName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
        ),
      ],
    );
  }
}