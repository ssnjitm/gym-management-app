import 'package:flutter/material.dart';
import '../../../../core/themes/color_schemes.dart';

class QuickActions extends StatelessWidget {
  final String gymId;
  final String role;

  const QuickActions({super.key, required this.gymId, required this.role});

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = role == 'super_admin';
    final canManage = role == 'manager' || role == 'super_admin';
    final items = <({IconData icon, String label, Color color, VoidCallback onTap})>[
      (
        icon: isSuperAdmin ? Icons.business_outlined : Icons.person_add_outlined,
        label: isSuperAdmin ? 'Gyms' : 'Members',
        color: AppColors.primary,
        onTap: () {
          Navigator.pushNamed(
            context,
            isSuperAdmin ? '/manage' : '/members',
            arguments: {'gymId': gymId},
          );
        },
      ),
      (
        icon: Icons.admin_panel_settings_outlined,
        label: canManage ? 'Manage' : 'Attendance',
        color: AppColors.success,
        onTap: () {
          Navigator.pushNamed(
            context,
            canManage ? '/manage' : '/attendance',
            arguments: {'gymId': gymId},
          );
        },
      ),
      (
        icon: Icons.receipt_long_outlined,
        label: isSuperAdmin ? 'Subscriptions' : 'Renewals',
        color: AppColors.warning,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/subscriptions',
            arguments: {'gymId': gymId},
          );
        },
      ),
      (
        icon: Icons.payments_outlined,
        label: 'Payments',
        color: AppColors.info,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/payments',
            arguments: {'gymId': gymId},
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _ActionCard(
              icon: item.icon,
              label: item.label,
              color: item.color,
              onTap: item.onTap,
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}