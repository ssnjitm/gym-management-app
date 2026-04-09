import 'package:flutter/material.dart';
import '../../domain/entities/home_entity.dart';

class RecentActivityList extends StatelessWidget {
  final List<RecentActivity> activities;
  
  const RecentActivityList({super.key, required this.activities});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: activity.thumbnail != null
                    ? NetworkImage(activity.thumbnail!)
                    : null,
                child: activity.thumbnail == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(activity.memberName),
              subtitle: Text(activity.action),
              trailing: Text(
                _formatTime(activity.time),
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          },
        ),
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No recent activities'),
            ),
          ),
      ],
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}