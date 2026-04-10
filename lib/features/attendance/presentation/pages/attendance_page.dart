import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/attendance_bloc.dart';

class AttendancePage extends StatefulWidget {
  final String gymId;

  const AttendancePage({super.key, required this.gymId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(AttendanceStarted(gymId: widget.gymId));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listenWhen: (p, c) => p.lastActionMessage != c.lastActionMessage || p.error != c.error,
      listener: (context, state) {
        final msg = state.lastActionMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
        final err = state.error;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.userMessage)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Check-in'),
            actions: [
              IconButton(
                onPressed: () => context.read<AttendanceBloc>().add(const AttendanceRefreshToday()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: 'Search member',
                  hintText: 'Name / code / phone',
                  border: const OutlineInputBorder(),
                  suffixIcon: state.loadingSearch
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            context.read<AttendanceBloc>().add(
                                  AttendanceSearchRequested(query: _searchCtrl.text),
                                );
                          },
                        ),
                ),
                onSubmitted: (_) => context.read<AttendanceBloc>().add(
                      AttendanceSearchRequested(query: _searchCtrl.text),
                    ),
              ),
              const SizedBox(height: 12),
              if (state.results.isNotEmpty) ...[
                Row(
                  children: [
                    const Text('Results', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<AttendanceBloc>().add(const AttendanceClearSearch());
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final m in state.results)
                  Card(
                    child: ListTile(
                      title: Text(m.fullName),
                      subtitle: Text('${m.memberCode} • ${m.phone}'),
                      trailing: FilledButton(
                        onPressed: state.actionInProgress
                            ? null
                            : () => context.read<AttendanceBloc>().add(
                                  AttendanceCheckInRequested(memberId: m.memberId),
                                ),
                        child: const Text('Check-in'),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Text("Today's check-ins", style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (state.loadingToday) const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const SizedBox(height: 8),
              if (!state.loadingToday && state.today.isEmpty)
                const Text('No check-ins yet.')
              else
                for (final a in state.today)
                  Card(
                    child: ListTile(
                      title: Text(a.member.fullName),
                      subtitle: Text(
                        'In: ${a.checkInTime.toLocal()}'
                        '${a.checkOutTime != null ? '\nOut: ${a.checkOutTime!.toLocal()}' : ''}',
                      ),
                      trailing: a.checkOutTime == null
                          ? OutlinedButton(
                              onPressed: state.actionInProgress
                                  ? null
                                  : () => context.read<AttendanceBloc>().add(
                                        AttendanceCheckOutRequested(attendanceId: a.attendanceId),
                                      ),
                              child: const Text('Check-out'),
                            )
                          : const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

