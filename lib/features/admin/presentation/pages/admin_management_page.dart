import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/crud_table_page.dart';
import '../../../../core/crud/crud_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminManagementPage extends StatelessWidget {
  final String gymId;

  const AdminManagementPage({super.key, required this.gymId});

  @override
  Widget build(BuildContext context) {
    final allItems = <({String title, String subtitle, CrudTableConfig config, Map<String, dynamic> Function()? defaults})>[
      (
        title: 'Gyms',
        subtitle: 'Manage gyms',
        config: const CrudTableConfig(
          table: 'gyms',
          idColumn: 'gym_id',
          titleColumn: 'gym_name',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'gym_name', label: 'Gym name'),
            CrudField(keyName: 'owner_name', label: 'Owner name'),
            CrudField(keyName: 'phone', label: 'Phone', keyboardType: TextInputType.phone),
            CrudField(keyName: 'email', label: 'Email', keyboardType: TextInputType.emailAddress),
            CrudField(keyName: 'address', label: 'Address', multiline: true),
            CrudField(keyName: 'gst_number', label: 'GST number'),
            CrudField(keyName: 'logo_url', label: 'Logo URL', keyboardType: TextInputType.url),
          ],
        ),
        defaults: null,
      ),
      (
        title: 'Gym settings',
        subtitle: 'Targets, currency, timezone',
        config: const CrudTableConfig(
          table: 'gym_settings',
          idColumn: 'setting_id',
          titleColumn: 'gym_id',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'gym_id', label: 'Gym ID'),
            CrudField(
              keyName: 'monthly_target',
              label: 'Monthly target',
              keyboardType: TextInputType.number,
              fieldType: CrudFieldType.number,
            ),
            CrudField(keyName: 'currency', label: 'Currency'),
            CrudField(keyName: 'timezone', label: 'Timezone'),
            CrudField(keyName: 'receipt_prefix', label: 'Receipt prefix'),
            CrudField(keyName: 'enable_biometric', label: 'Enable biometric', fieldType: CrudFieldType.boolean),
          ],
        ),
        defaults: () => {'gym_id': gymId},
      ),
      (
        title: 'Staff',
        subtitle: 'Admins, managers, reception, trainers',
        config: const CrudTableConfig(
          table: 'staff',
          idColumn: 'staff_id',
          titleColumn: 'full_name',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'gym_id', label: 'Gym ID'),
            CrudField(keyName: 'full_name', label: 'Full name'),
            CrudField(keyName: 'email', label: 'Email', keyboardType: TextInputType.emailAddress),
            CrudField(keyName: 'phone', label: 'Phone', keyboardType: TextInputType.phone),
            CrudField(keyName: 'role', label: 'Role (super_admin/manager/reception/trainer)'),
            CrudField(keyName: 'is_active', label: 'Is active', fieldType: CrudFieldType.boolean),
          ],
        ),
        defaults: () => {'gym_id': gymId},
      ),
      (
        title: 'Members',
        subtitle: 'Member profiles',
        config: const CrudTableConfig(
          table: 'members',
          idColumn: 'member_id',
          titleColumn: 'full_name',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'gym_id', label: 'Gym ID'),
            CrudField(keyName: 'member_code', label: 'Member code'),
            CrudField(keyName: 'full_name', label: 'Full name'),
            CrudField(keyName: 'phone', label: 'Phone', keyboardType: TextInputType.phone),
            CrudField(keyName: 'email', label: 'Email', keyboardType: TextInputType.emailAddress),
            CrudField(keyName: 'address', label: 'Address', multiline: true),
            CrudField(keyName: 'date_of_birth', label: 'DOB (YYYY-MM-DD)', fieldType: CrudFieldType.date),
            CrudField(keyName: 'gender', label: 'Gender (male/female/other)'),
            CrudField(keyName: 'status', label: 'Status (active/inactive/frozen/expired/grace)'),
            CrudField(keyName: 'notes', label: 'Notes', multiline: true),
          ],
        ),
        defaults: () => {'gym_id': gymId},
      ),
      (
        title: 'Packages',
        subtitle: 'Plans and prices',
        config: const CrudTableConfig(
          table: 'packages',
          idColumn: 'package_id',
          titleColumn: 'package_name',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'gym_id', label: 'Gym ID'),
            CrudField(keyName: 'package_name', label: 'Package name'),
            CrudField(keyName: 'duration_type', label: 'Duration type (monthly/quarterly/half_yearly/yearly)'),
            CrudField(
              keyName: 'duration_days',
              label: 'Duration days',
              keyboardType: TextInputType.number,
              fieldType: CrudFieldType.number,
            ),
            CrudField(
              keyName: 'price',
              label: 'Price',
              keyboardType: TextInputType.number,
              fieldType: CrudFieldType.number,
            ),
            CrudField(keyName: 'features', label: 'Features (json)', multiline: true, fieldType: CrudFieldType.json),
            CrudField(keyName: 'is_active', label: 'Is active', fieldType: CrudFieldType.boolean),
          ],
        ),
        defaults: () => {'gym_id': gymId},
      ),
      (
        title: 'Subscriptions',
        subtitle: 'Member subscriptions',
        config: const CrudTableConfig(
          table: 'subscriptions',
          idColumn: 'subscription_id',
          titleColumn: 'member_id',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'member_id', label: 'Member ID'),
            CrudField(keyName: 'package_id', label: 'Package ID'),
            CrudField(keyName: 'start_date', label: 'Start date (YYYY-MM-DD)', fieldType: CrudFieldType.date),
            CrudField(keyName: 'expiry_date', label: 'Expiry date (YYYY-MM-DD)', fieldType: CrudFieldType.date),
            CrudField(keyName: 'status', label: 'Status (active/expired/cancelled/grace)'),
            CrudField(
              keyName: 'amount_paid',
              label: 'Amount paid',
              keyboardType: TextInputType.number,
              fieldType: CrudFieldType.number,
            ),
            CrudField(keyName: 'payment_mode', label: 'Payment mode (cash/card/upi/bank_transfer)'),
            CrudField(keyName: 'payment_reference', label: 'Payment reference'),
            CrudField(keyName: 'created_by', label: 'Created by (staff_id)'),
          ],
        ),
        defaults: null,
      ),
      (
        title: 'Payments',
        subtitle: 'Receipts and payment history',
        config: const CrudTableConfig(
          table: 'payments',
          idColumn: 'payment_id',
          titleColumn: 'receipt_number',
          orderBy: 'created_at',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'member_id', label: 'Member ID'),
            CrudField(keyName: 'subscription_id', label: 'Subscription ID'),
            CrudField(keyName: 'amount', label: 'Amount', keyboardType: TextInputType.number, fieldType: CrudFieldType.number),
            CrudField(keyName: 'payment_mode', label: 'Payment mode (cash/card/upi/bank_transfer)'),
            CrudField(keyName: 'payment_date', label: 'Payment date (YYYY-MM-DD)', fieldType: CrudFieldType.date),
            CrudField(keyName: 'receipt_number', label: 'Receipt number'),
            CrudField(keyName: 'notes', label: 'Notes', multiline: true),
            CrudField(keyName: 'recorded_by', label: 'Recorded by (staff_id)'),
          ],
        ),
        defaults: null,
      ),
      (
        title: 'Attendance',
        subtitle: 'Daily check-ins',
        config: const CrudTableConfig(
          table: 'attendance',
          idColumn: 'attendance_id',
          titleColumn: 'member_id',
          orderBy: 'check_in_time',
          orderAscending: false,
          fields: [
            CrudField(keyName: 'member_id', label: 'Member ID'),
            CrudField(keyName: 'gym_id', label: 'Gym ID'),
            CrudField(keyName: 'check_in_time', label: 'Check-in time (timestamp)'),
            CrudField(keyName: 'check_out_time', label: 'Check-out time (timestamp)'),
            CrudField(keyName: 'marked_by', label: 'Marked by (staff_id)'),
            CrudField(keyName: 'attendance_date', label: 'Attendance date (YYYY-MM-DD)', fieldType: CrudFieldType.date),
          ],
        ),
        defaults: () => {'gym_id': gymId},
      ),
    ];

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final role = state is AuthAuthenticated ? state.staff.role.toLowerCase() : null;
        final isSuperAdmin = role == 'super_admin';
        final isManager = role == 'manager';
        final allowed = isSuperAdmin || isManager;

        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!allowed) {
          return Scaffold(
            appBar: AppBar(title: const Text('Management')),
            body: const Center(
              child: Text('Access denied. Only super admin or manager can open management.'),
            ),
          );
        }

        final items = isSuperAdmin
            ? allItems
            : allItems.where((it) => it.title != 'Gyms').toList(growable: false);

        return Scaffold(
          appBar: AppBar(title: const Text('Management')),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 1.5,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CrudTablePage(
                          config: item.config,
                          repository: context.read<CrudRepository>(),
                          defaultInsertValues: item.defaults,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

