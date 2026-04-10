import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';
import '../bloc/payments_state.dart';

class PaymentsPage extends StatefulWidget {
  final String gymId;

  const PaymentsPage({super.key, required this.gymId});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentsBloc>().add(PaymentsStarted(gymId: widget.gymId));
  }

  Future<void> _showRecordDialog() async {
    final memberCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final receiptCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String mode = 'cash';
    DateTime paymentDate = DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInner) {
            return AlertDialog(
              title: const Text('Record payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: memberCtrl,
                      decoration: const InputDecoration(labelText: 'Member ID'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: subCtrl,
                      decoration: const InputDecoration(labelText: 'Subscription ID (optional)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: mode,
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('cash')),
                        DropdownMenuItem(value: 'card', child: Text('card')),
                        DropdownMenuItem(value: 'upi', child: Text('upi')),
                        DropdownMenuItem(value: 'bank_transfer', child: Text('bank_transfer')),
                      ],
                      onChanged: (v) => setInner(() => mode = v ?? 'cash'),
                      decoration: const InputDecoration(labelText: 'Payment mode'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: receiptCtrl,
                      decoration: const InputDecoration(labelText: 'Receipt number (optional)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Date: ${paymentDate.toIso8601String().split('T').first}'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: paymentDate,
                            );
                            if (picked != null) {
                              setInner(() => paymentDate = picked);
                            }
                          },
                          child: const Text('Pick'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;
    if (!mounted) return;

    final memberId = memberCtrl.text.trim();
    final amount = num.tryParse(amountCtrl.text.trim());
    if (memberId.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member ID and valid amount are required')),
      );
      return;
    }

    context.read<PaymentsBloc>().add(
          PaymentRecordRequested(
            gymId: widget.gymId,
            memberId: memberId,
            subscriptionId: subCtrl.text.trim().isEmpty ? null : subCtrl.text.trim(),
            amount: amount,
            paymentMode: mode,
            paymentDate: paymentDate,
            receiptNumber: receiptCtrl.text.trim().isEmpty ? null : receiptCtrl.text.trim(),
            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentsBloc, PaymentsState>(
      listenWhen: (p, c) => p.error != c.error || p.lastMessage != c.lastMessage,
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.lastMessage != null && state.lastMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.lastMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Payments'),
            actions: [
              IconButton(
                onPressed: () => context.read<PaymentsBloc>().add(PaymentsRefreshRequested(gymId: widget.gymId)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.actionInProgress ? null : _showRecordDialog,
            icon: state.actionInProgress
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(state.actionInProgress ? 'Saving...' : 'Record Payment'),
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.items.isEmpty
                  ? const Center(child: Text('No payments found.'))
                  : ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = state.items[index];
                        final date = p.paymentDate.toIso8601String().split('T').first;
                        return ListTile(
                          title: Text('${p.memberName}  •  Rs ${p.amount.toStringAsFixed(2)}'),
                          subtitle: Text('${p.paymentMode} • $date • ${p.receiptNumber ?? 'no receipt'}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/member',
                            arguments: {'memberId': p.memberId},
                          ),
                        );
                      },
             ),
        );
      },
    );
  }
}

