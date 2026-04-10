import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/color_schemes.dart';
import '../bloc/member_detail_bloc.dart';

class MemberDetailPage extends StatefulWidget {
  final String memberId;

  const MemberDetailPage({super.key, required this.memberId});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<MemberDetailBloc>().add(MemberDetailStarted(memberId: widget.memberId));
  }

  Future<void> _showRecordPaymentDialog(MemberDetailState state) async {
    final detail = state.detail;
    if (detail == null) return;

    final amountCtrl = TextEditingController();
    String paymentMode = 'cash';
    final notesCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (NPR)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: paymentMode,
              decoration: const InputDecoration(labelText: 'Payment mode'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                DropdownMenuItem(value: 'bank_transfer', child: Text('Bank transfer')),
              ],
              onChanged: (v) => paymentMode = v ?? 'cash',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return;
    if (!mounted) return;

    context.read<MemberDetailBloc>().add(
          MemberDetailRecordPaymentRequested(
            memberId: detail.member.memberId,
            subscriptionId: detail.currentSubscription?.subscriptionId,
            amount: amount,
            paymentMode: paymentMode,
            paymentDate: DateTime.now(),
            receiptNumber: null,
            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberDetailBloc, MemberDetailState>(
      listenWhen: (p, c) => p.lastMessage != c.lastMessage || p.error != c.error,
      listener: (context, state) {
        final msg = state.lastMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
        final err = state.error;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.userMessage)));
        }
      },
      builder: (context, state) {
        final detail = state.detail;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Member details'),
            actions: [
              IconButton(
                onPressed: () => context.read<MemberDetailBloc>().add(const MemberDetailRefreshRequested()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: detail == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: state.actionInProgress ? null : () => _showRecordPaymentDialog(state),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Record payment'),
                ),
          body: state.loading && detail == null
              ? const Center(child: CircularProgressIndicator())
              : detail == null
                  ? const Center(child: Text('No data'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<MemberDetailBloc>().add(const MemberDetailRefreshRequested());
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _header(detail),
                          const SizedBox(height: 16),
                          _subscriptionCard(detail),
                          const SizedBox(height: 16),
                          _sectionTitle('Attendance history (latest 50)'),
                          _attendanceList(detail),
                          const SizedBox(height: 16),
                          _sectionTitle('Payment history (latest 50)'),
                          _paymentsList(detail),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _header(dynamic detail) {
    final m = detail.member;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              m.fullName.isNotEmpty ? m.fullName.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${m.memberCode} • ${m.phone}', style: const TextStyle(color: AppColors.grey600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionCard(dynamic detail) {
    final sub = detail.currentSubscription;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100),
      ),
      child: sub == null
          ? Row(
              children: [
                const Icon(Icons.card_membership_outlined, color: AppColors.grey500),
                const SizedBox(width: 8),
                const Expanded(child: Text('No subscription found')),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Renew'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current subscription', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Status: ${sub.status}'),
                Text('Start: ${sub.startDate.toIso8601String().split('T')[0]}'),
                Text('Expiry: ${sub.expiryDate.toIso8601String().split('T')[0]}'),
                Text('Paid: NPR ${sub.amountPaid.toStringAsFixed(0)} (${sub.paymentMode})'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            final amountCtrl = TextEditingController(text: detail.currentSubscription?.amountPaid.toStringAsFixed(0));
                            final packageIdCtrl = TextEditingController();
                            final paymentRefCtrl = TextEditingController();
                            String paymentMode = 'cash';
                            DateTime pickedExpiry = sub.expiryDate;

                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('Renew/Upgrade'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              controller: packageIdCtrl,
                                              decoration: const InputDecoration(
                                                labelText: 'Package ID',
                                                hintText: 'Select or paste package_id',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextFormField(
                                              controller: amountCtrl,
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Amount (NPR)',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            DropdownButtonFormField<String>(
                                              value: paymentMode,
                                              decoration: const InputDecoration(labelText: 'Payment mode'),
                                              items: const [
                                                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                                DropdownMenuItem(value: 'card', child: Text('Card')),
                                                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                                                DropdownMenuItem(value: 'bank_transfer', child: Text('Bank transfer')),
                                              ],
                                              onChanged: (v) => paymentMode = v ?? 'cash',
                                            ),
                                            const SizedBox(height: 12),
                                            TextFormField(
                                              controller: paymentRefCtrl,
                                              decoration: const InputDecoration(
                                                labelText: 'Payment reference (optional)',
                                                hintText: 'Used as receipt_number in this demo',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Expiry: ${pickedExpiry.toIso8601String().split('T')[0]}',
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Pick expiry date',
                                                  icon: const Icon(Icons.calendar_month_outlined),
                                                  onPressed: () async {
                                                    final date = await showDatePicker(
                                                      context: context,
                                                      initialDate: pickedExpiry,
                                                      firstDate: DateTime(2020),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (date != null) {
                                                      setState(() => pickedExpiry = date);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Renew')),
                                      ],
                                    );
                                  },
                                );
                              },
                            );

                            if (ok != true) return;
                            if (!mounted) return;

                            final packageId = packageIdCtrl.text.trim();
                            if (packageId.isEmpty) return;

                            final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                            if (amount <= 0) return;

                            context.read<MemberDetailBloc>().add(
                                  MemberDetailRenewSubscriptionRequested(
                                    memberId: detail.member.memberId,
                                    packageId: packageId,
                                    startDate: now,
                                    expiryDate: pickedExpiry,
                                    amountPaid: amount,
                                    paymentMode: paymentMode,
                                    paymentReference: paymentRefCtrl.text.trim().isEmpty ? null : paymentRefCtrl.text.trim(),
                                  ),
                                );
                          },
                          child: const Text('Renew/Upgrade'),
                        ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Freeze'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _attendanceList(dynamic detail) {
    if (detail.attendance.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('No attendance records.'),
      );
    }
    return Column(
      children: [
        for (final a in detail.attendance)
          Card(
            child: ListTile(
              leading: const Icon(Icons.how_to_reg_outlined),
              title: Text(a.attendanceDate.toIso8601String().split('T')[0]),
              subtitle: Text(
                'In: ${a.checkInTime.toLocal()}'
                '${a.checkOutTime != null ? '\nOut: ${a.checkOutTime!.toLocal()}' : ''}',
              ),
            ),
          ),
      ],
    );
  }

  Widget _paymentsList(dynamic detail) {
    if (detail.payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('No payments.'),
      );
    }
    return Column(
      children: [
        for (final p in detail.payments)
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text('NPR ${p.amount.toStringAsFixed(0)} • ${p.paymentMode}'),
              subtitle: Text(p.paymentDate.toIso8601String().split('T')[0]),
              trailing: p.receiptNumber == null ? null : Text(p.receiptNumber!),
            ),
          ),
      ],
    );
  }
}

